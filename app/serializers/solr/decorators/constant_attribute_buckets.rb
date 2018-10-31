module SOLR
  module Decorators
    # = Constant Attribute Buckets
    #
    # Module Constant Attribute Buckets generates methods based upon the attribute name and the set of constant names.
    module ConstantAttributeBuckets
      extend ActiveSupport::Concern

      class_methods do
        def bucket(attribute_name, constants_class)
          constants_class.constants.each do |constant_name|
            method_name = "#{attribute_name}_#{constant_name.downcase}"
            define_method(method_name) do
              matcher = "#{method_name}?".to_sym
              service.which_concepts(&matcher)
            end
          end
        end
      end
    end
  end
end
