module CatalogMessage
  #= Catalog Message Base
  #
  # A Catalog Message Base class specifies the layout and target models of a message.
  #
  # == Configuration
  #
  # The following methods enable the message to be specified:
  #
  # * model_name: the name of the model class used to persist the message data
  # * attribute_mapping: (optional) a hash to map attribute names from the message to the model
  # * propagate: (optional) attribute(s) to copy to all associations
  #
  # == Associations
  #
  # Nested data can specified with either a has_one or has_many association.
  class Base
    include CatalogMessage::Associations
    class_attribute :_model_name, instance_writer: false, instance_predicate: false
    class_attribute :_attribute_mapping, instance_writer: false, instance_predicate: false
    class_attribute :_propagate_down, instance_writer: false, instance_predicate: false

    def self.model_name(name)
      self._model_name = name
    end

    def self.attribute_mapping(mapping)
      self._attribute_mapping = mapping
    end

    def self.propagate(attributes)
      self._propagate_down = [attributes].flatten
    end

    def initialize(data)
      @data = data
    end

    # returns a hash representing the message data
    def data_attributes
      @data
    end

    def records
      [to_active_record] + children.flat_map(&:records)
    end

    private

    def mapped_attributes(message_attributes = nil)
      attributes = message_attributes || data_attributes
      return attributes if _attribute_mapping.nil?

      _attribute_mapping.each_with_object(attributes) do |(model_name, message_name), memo|
        memo[model_name] = memo.delete(message_name)
      end
    end

    # returns a hash of attributes to be passed into the models <tt>attributes=</tt> method
    def modelized_attributes(message_attributes = nil)
      mapped_attributes(message_attributes).slice(*model_class.attribute_names)
    end

    def to_active_record(message_attributes = nil)
      model_class.new(modelized_attributes(message_attributes))
    end

    def model_class
      self.class._model_name.constantize
    end
  end
end
