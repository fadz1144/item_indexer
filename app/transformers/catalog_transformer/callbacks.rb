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
      %i[before after].each do |preposition|
        %i[transform save].each do |event|
          callback_name = "#{preposition}_#{event}".to_sym
          define_method(callback_name) do |method_name = nil, &block|
            add_callback(callback_name, method_name, &block)
          end
        end
      end

      def transform_callbacks
        @transform_callbacks ||= Hash.new { |h, k| h[k] = [] }
      end

      private

      def add_callback(callback_name, method_name, &block)
        transform_callbacks[callback_name] << (method_name.presence || block)
      end
    end

    def with_callbacks(event, target)
      run_callbacks("before_#{event}", target)
      yield
      run_callbacks("after_#{event}", target)
    end

    private

    def run_callbacks(callback_name, target)
      self.class.transform_callbacks[callback_name.to_sym].each do |callback|
        callback.respond_to?(:call) ? callback.call(target) : public_send(callback, target)
      end
    end
  end
end
