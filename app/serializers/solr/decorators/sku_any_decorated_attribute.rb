module SOLR
  module Decorators
    module SkuAnyDecoratedAttribute
      extend ActiveSupport::Concern

      module ClassMethods
        # field_name: the name of a boolean sku field
        # returns: true if any underlying sku field values are true, false otherwise
        #
        def decorate_sku_any(field_name, **args)
          field = RollupField.new(args.merge(field_name: field_name))
          define_decorated_sku_any_method(field)
        end

        def define_decorated_sku_any_method(field)
          define_method(field.field_name) do
            service.decorated_skus_iterator_any(&field.field)
          end
        end
      end
    end
  end
end
