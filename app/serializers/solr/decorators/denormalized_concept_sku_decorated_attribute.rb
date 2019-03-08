module SOLR
  module Decorators
    module DenormalizedConceptSkuDecoratedAttribute
      extend ActiveSupport::Concern

      module ClassMethods
        # for single value fields that are on the concept sku level and should be indexed on the sku only (not product)
        # given e.g. field 'foo', this decorator will yield methods for each concept like `bbby__foo`, `ca__foo`,
        # `okl__foo`, etc...
        def decorate_denormalized_concept_sku(field_name, **args)
          field = RollupField.new(args.merge(field_name: field_name))
          define_concept_skus_methods(field)
        end

        private

        def define_concept_skus_methods(field)
          CatModels::Concept::CODES.keys.each do |concept_code|
            field_name = concept_field_name(concept_code, field.field_name)
            define_method(field_name) do
              service.decorated_skus_iterator(&field_name.to_sym).first
            end
          end
        end

        def concept_field_name(concept_code, field_name)
          CatModels::ConceptSpecificAttributes.field_name(concept_code, field_name)
        end
      end
    end
  end
end
