module SOLR
  module Decorators
    module SkuUniqDecoratedAttribute
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
        def decorate_sku_uniq(field_name, **args)
          field = RollupField.new(args.merge(field_name: field_name))
          define_decorated_unique_method(field)
        end

        def define_decorated_unique_method(field)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{field.field_name}
            RollupField.decorated_skus_uniq_values(service, :#{field.field}, #{field.quoted_group_action}, #{field.quoted_format})
          end
          RUBY
        end
      end
    end
  end
end
