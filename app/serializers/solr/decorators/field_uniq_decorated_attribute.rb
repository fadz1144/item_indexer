module SOLR
  module Decorators
    module FieldUniqDecoratedAttribute
      extend ActiveSupport::Concern

      module ClassMethods
        # Defines how we decorate using field uniqe values
        # It just passes through to the RollupField but this is the entrypoint / DSL
        # field_name: the name of the field we want written to SOLR
        # group action: should be one of the following:
        #              :min, :max, :avg
        # format: should be one of the following:
        #              :currency_cents, :currency
        #
        # TODO: rename this method to decorate
        def decorate_field_uniq(field_name, **args)
          field = RollupField.new(args.merge(field_name: field_name))
          define_field_unique_method(field)
        end

        def define_field_unique_method(field)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{field.field_name}
            RollupField.field_unique_values_result(service, :#{field.field}, #{field.quoted_group_action}, #{field.quoted_format})
          end
          RUBY
        end
      end
    end
  end
end
