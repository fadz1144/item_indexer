module CatalogMessage
  #= Catalog Message Base
  #
  # A Catalog Message Base class specifies the layout and target models of a message.
  #
  # == Configuration
  #
  # The following methods enable the message to be specified:
  #
  # * model: the name of the model class used to persist the message data
  # * attribute_mapping: (optional) a hash to map attribute names from the message to the model
  # * propagate_attributes: (optional) attribute(s) to copy to all associations
  #
  # == Associations
  #
  # Nested data can specified with either a has_one or has_many association.
  class Base
    include CatalogMessage::Associations
    class_attribute :model_name, instance_accessor: false, instance_predicate: false
    class_attribute :attribute_map, instance_accessor: false, instance_predicate: false
    class_attribute :propagate, instance_accessor: false, instance_predicate: false

    def self.model(name)
      self.model_name = name.to_s
    end

    def self.attribute_mapping(mapping)
      self.attribute_map = mapping.stringify_keys
    end

    def self.propagate_attributes(attributes)
      self.propagate = [attributes].flatten
    end

    def self.model_class
      model_name.constantize
    end

    def initialize(data)
      @data = data
    end

    # returns a hash representing the message data
    def data_attributes
      @data
    end

    def records
      r = to_active_record
      [r] + children(r).flat_map(&:records)
    end

    private

    def mapped_attributes
      attributes = data_attributes
      return attributes if self.class.attribute_map.nil?

      # if any attribute names are mapped, then replace message key with attribute name
      self.class.attribute_map.each_with_object(attributes.clone) do |(attribute_name, message_key), memo|
        memo[attribute_name] = memo.delete(message_key)
      end
    end

    # returns a hash of attributes to be passed into the models <tt>attributes=</tt> method
    def modelized_attributes
      mapped_attributes.slice(*self.class.model_class.attribute_names)
    end

    def to_active_record
      self.class.model_class.new(modelized_attributes)
    end
  end
end
