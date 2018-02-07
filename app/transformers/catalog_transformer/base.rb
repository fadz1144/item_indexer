module CatalogTransformer
  # = Catalog Transformer Base
  #
  # A Catalog Transformer Base class specifies the transformation from one set of tables to another.
  class Base
    include CatalogTransformer::Associations
    include CatalogTransformer::Attributes
    include CatalogTransformer::SourceDecorations
    include CatalogTransformer::SourceClassAccessors
    attr_reader :source

    def self.source_relation
      source_class.includes(source_includes)
    end

    def self.source_includes
      (source_includes_from_associations | source_includes_from_attributes).flatten
    end

    def self.target_relation
      target_class.includes(target_includes)
    end

    def initialize(source)
      @source = source
      @source.extend(self.class.decorator) if self.class.decorator?
      @source.extend(self.class.decorations) if self.class.decorations?
    end

    def apply_transformation(target, excluded_attributes = nil)
      target.assign_attributes(attribute_values.except(excluded_attributes))
      apply_association_transformations(target)
    end

    def attribute_values
      attributes.each_with_object({}) do |attribute, memo|
        record = @source.public_send(attribute.source_record_name)
        next if record.nil?
        memo[attribute.name] = attribute_value(record, attribute.source_name)
      end
    end

    private

    def attribute_value(record, attribute_name)
      record.public_send(attribute_name)
    rescue => e
      raise CatalogTransformer::Errors::CouldNotReadAttribute.new(self.class.name, record.class.name, attribute_name,
                                                                  e.message)
    end

    def apply_association_transformations(target)
      associations.each do |association|
        handler = association.handler_class.new(@source, target)
        handler.transform_association(association)
      end
    end
  end
end
