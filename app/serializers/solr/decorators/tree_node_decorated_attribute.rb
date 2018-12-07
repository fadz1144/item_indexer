module SOLR
  module Decorators
    module TreeNodeDecoratedAttribute
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
        def decorate_tree_node(field_name, **args)
          field = RollupField.new(args.merge(field_name: field_name))
          define_tree_node_method(field, args[:tree])
        end

        def define_tree_node_method(field, tree)
          define_method(field.field_name) do
            RollupField.sku_tree_node_result(service, tree.to_sym, field.field, field.group_action, field.format)
          end
        end
      end
    end
  end
end
