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
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{field.field_name}
            RollupField.sku_pricing_result(service, :#{field.field}, #{field.quoted_group_action}, #{field.quoted_format})
          end
          RUBY
        end
      end
    end
  end
end
