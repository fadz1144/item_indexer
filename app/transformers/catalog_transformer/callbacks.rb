module CatalogTransformer
  # Callbacks enable a transformer to trigger logic before and/or after the transformation.
  #
  # Define the callback in the transformer with either a method name or a block. When the callback is run it will
  # receive the target record as a parameter.
  #
  # = Examples
  #
  #   after_transform :celebrate
  #   after_transform { |target| puts "Transformation complete for #{target}!" }
  #   after_transform do |target|
  #     target.celebrate = "Let's"
  #   end
  #
  #   def celebrate(target)
  #     target.good_times = true
  #   end
  module Callbacks
    extend ActiveSupport::Concern

    module ClassMethods
      def before_transform(method_name = nil, &block)
        add_callback(:before, method_name, &block)
      end

      def after_transform(method_name = nil, &block)
        add_callback(:after, method_name, &block)
      end

      def transform_callbacks
        @transform_callbacks ||= Hash.new { |h, k| h[k] = [] }
      end

      private

      def add_callback(preposition, method_name, &block)
        transform_callbacks[preposition] << (method_name.presence || block)
      end
    end

    def run_callbacks(preposition, target)
      self.class.transform_callbacks[preposition.to_sym].each do |callback|
        callback.respond_to?(:call) ? callback.call(target) : public_send(callback, target)
      end
    end
  end
end
