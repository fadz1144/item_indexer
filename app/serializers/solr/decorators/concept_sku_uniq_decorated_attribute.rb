module SOLR
  module Decorators
    module ConceptSkuUniqDecoratedAttribute
      extend ActiveSupport::Concern

      module ClassMethods
        # Defines how we decorate a tree node
        # It just passes through to the RollupField but this is the entrypoint / DSL
        # field_name: the name of the field we want written to SOLR
        # group action: should be one of the following:
        #              :min, :max, :avg
        # format: should be one of the following:
        #              :currency_cents, :currency
        #
        def decorate_concept_sku_uniq(field_name, **args)
          field = RollupField.new(args.merge(field_name: field_name))
          define_concept_skus_method(field)
        end

        def define_concept_skus_method(field)
          define_method(field.field_name) do
            uniq_value = service.concept_skus_iterator_uniq(&field.field.to_sym)
            field.group_and_format(uniq_value)
          end
        end
      end
    end
  end
end
