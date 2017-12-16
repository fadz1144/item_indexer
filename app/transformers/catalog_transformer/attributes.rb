module CatalogTransformer
  module Attributes
    extend ActiveSupport::Concern

    # Attributes are a set of class methods that enable a transformer to specify the attributes to be populated and the
    # source for each attribute.
    #
    # == Target Name
    #
    # The target_name specifies the target model for the transformation. The model is used to determine the list of
    # attributes to read and write. If the transformer name matches the model name, then the model name does not need
    # to be specified. For example, transformer Transform::Transformers::OKL::ConceptSku uses model
    # CatModels::ConceptSku as the target, so it can be derived. (Note: namespace CatModels is always used in deriving
    # model names.)
    #
    # == Match Keys
    #
    # The match keys are used by the transformation service to determine how to match up source transactions with target
    # transactions. For example, the match key to connect the concept product table to the product revisions table is
    # source_product_id:
    #
    #   match_keys :source_product_id
    #
    # Because the match key is the same on the target and the source, the source key does not need to be specified. If
    # the attribute names to not match, then the name of the source key must be provided as well. For example, if the
    # target record carried the key target_id while the source record carried the key source_id, the match keys would be
    # specified as follows:
    #
    #   match keys :target_id, source_key: :source_id
    #
    # Top-level attributes must specify match keys. (Transformers that are only used as associations do not need to
    # specify match keys.)
    #
    # == Attribute
    #
    # As a starting point, the transformer uses all the attributes of the target model. Attributes only need to be
    # specified when the name is different on the source or it comes from an association.
    #
    # See CatalogTransformer::Attributes::Attribute for examples.
    #
    # == References
    #
    # If a model belongs to another but does not do any updates via the transformation, the references method allows it
    # to be specified to enable eager loading. In some cases, references are auto-generated.
    #
    # See CatalogTransformer::Attributes::ReferenceAttribute for examples.
    #
    # == Exclusions
    #
    # By default, the transformer does not try to set the model's primary key or timestamps. Additionally, the exclude
    # method takes a list of attributes that should also be skipped. If the primary key needs to be assigned, use the
    # allow_primary_key parameter (the default is false, so it only makes sense as true).
    #
    # Currently the product membership attribute membership_hash is not implemented, so it is excluded:
    #
    #     exclude :membership_hash
    #
    #   The Sku transformer requires the primary key, so it notes that:
    #
    #     exclude allow_primary_key: true
    #
    #   Both can be supplied:
    #
    #     exclude :source_sku_id, :another_field, allow_primary_key: true
    module ClassMethods
      attr_reader :target_match_key, :source_match_key

      def target_name(target_name)
        @target_name = target_name
      end

      def match_keys(target_key, source_key: nil)
        @target_match_key = target_key
        @source_match_key = source_key || target_key
      end

      # see CatalogTransformer::Attributes::Attribute for examples
      def attribute(name, **options)
        attribute_overrides[name.to_s] = CatalogTransformer::Attributes::Attribute.new(name, options)
      end

      # see CatalogTransformer::Attributes::ReferenceAttribute for examples
      def references(name, **options)
        association = target_class.reflect_on_association(name)
        raise CatalogTransformer::Errors::AssociationNotDefined.new(target_class, name) if association.nil?
        attribute_overrides[association.foreign_key] =
          CatalogTransformer::Attributes::ReferenceAttribute.new(name, options)
      end

      def exclude(*names, allow_primary_key: false)
        exclusions.push(*names.map(&:to_s))
        @allow_primary_key = allow_primary_key
      end

      def target_class
        (@target_name || "CatModels::#{name.demodulize}").constantize
      end

      def attributes
        @attributes ||= merge_overrides_and_model
      end

      def source_includes_from_attributes
        attributes.map(&:source_includes).compact.uniq
      end

      private

      def attribute_overrides
        @attribute_overrides ||= {}
      end

      def exclusions
        @exclusions ||= []
      end

      def merge_overrides_and_model
        overrides = references_from_model.merge(attribute_overrides)
        attributes_from_model.reject { |name| exclusions.include? name }
                             .map do |name|
          overrides[name] || CatalogTransformer::Attributes::Attribute.new(name)
        end
      end

      # generates list of attributes with matching names on source and target
      def attributes_from_model
        mc = target_class
        exclude = %w[updated_at created_at]
        exclude << mc.primary_key unless @allow_primary_key
        mc.attribute_names - exclude
      end

      # generates list of references for belong_to associations with matching source association name
      def references_from_model
        target = target_class.reflect_on_all_associations.select(&:belongs_to?)
        source_names = source_class.reflect_on_all_associations.reject(&:collection?).map(&:name)

        target.select { |bt| source_names.include? bt.name }
              .each_with_object({}) do |bt, memo|
          memo[bt.foreign_key] = CatalogTransformer::Attributes::ReferenceAttribute.new(bt.name)
        end
      end
    end

    def attributes
      self.class.attributes
    end
  end
end
