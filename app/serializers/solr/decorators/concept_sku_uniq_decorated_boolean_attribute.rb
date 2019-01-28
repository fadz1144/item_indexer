module SOLR
  module Decorators
    module ConceptSkuUniqDecoratedBooleanAttribute
      extend ActiveSupport::Concern

      module ClassMethods
        # boolean_field_name: the name of a boolean concept sku field
        # returns: an array of concept ids for which that field evaluates to true
        #
        def decorate_concepts_for_true_concept_sku_boolean(boolean_field_name, **args)
          field = RollupField.new(args.merge(field_name: boolean_field_name))
          define_conditional_concept_skus_method(field)
        end

        def define_conditional_concept_skus_method(field)
          define_method(field.field_name) do
            uniq_matching_concept_ids = service.concept_skus_iterator_uniq do |concept_sku|
              concept_sku.concept_id if concept_sku.send(field.field.to_sym)
            end
            field.group_and_format(uniq_matching_concept_ids)
          end
        end
      end
    end
  end
end
