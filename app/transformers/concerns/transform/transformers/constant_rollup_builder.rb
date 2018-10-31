module Transform
  module Transformers
    #= Constant Rollup Builder
    #
    # Module ConstantRollupBuilder provides method define_best_value_rollup_method. It takes the name of the attribute
    # along with a sorted list of values. The method looks through the items passed in as arguments and returns the
    # first value based upon the sorted order. The method can take either items or a list of values.
    module ConstantRollupBuilder
      extend ActiveSupport::Concern

      included do
        cattr_accessor :sorted_rollup_values
        self.sorted_rollup_values = {}
      end

      class_methods do
        def define_best_value_rollup_method(attribute_name, sorted_values)
          sorted_rollup_values[attribute_name] = sorted_values

          define_method("#{attribute_name}_rollup") do |items|
            values = items.first.is_a?(String) ? items : items.map(&attribute_name)
            sorted = sorted_rollup_values[attribute_name]
            values.min_by { |item| sorted.index(item) || 999 }
          end
        end
      end
    end
  end
end
