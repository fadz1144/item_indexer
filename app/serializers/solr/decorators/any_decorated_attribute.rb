module SOLR
  module Decorators
    module AnyDecoratedAttribute
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
        # TODO: rename this method to decorate
        def decorate_any(field_name, **args)
          field = RollupField.new(args.merge(field_name: field_name))
          define_concept_skus_any_method(field)
        end

        def define_concept_skus_any_method(field)
          define_method(field.field_name) do
            RollupField.concept_skus_any(service, field.field.to_sym, field.group_action, field.format)
          end
        end
      end
    end
  end
end
