module SOLR
  module Decorators
    module PricingDecoratedAttribute
      extend ActiveSupport::Concern

      module ClassMethods
        # Defines how we decorate a pricing field
        # It just passes through to the RollupField but this is the entrypoint / DSL
        # field_name: the name of the field we want written to SOLR
        # group action: should be one of the following:
        #              :min, :max, :avg
        # format: should be one of the following:
        #              :currency_cents, :currency
        #
        # TODO: rename this method to decorate
        def decorate_pricing(field_name, **args)
          field = RollupField.new(args.merge(field_name: field_name))

          define_pricing_method(field)
        end

        def define_pricing_method(field)
          define_method(field.field_name) do
            pricing_value = service.sku_pricing_field_values(field.field)
            RollupField.group_and_format_results(pricing_value, field.group_action, field.format)
          end
        end
      end
    end
  end
end
