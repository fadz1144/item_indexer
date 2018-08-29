module Transform
  module Transformers
    module DimensionDisplay
      def item_dimension_display
        dimension_display(item_length, item_width, item_height)
      end

      def shipping_dimension_display
        dimension_display(shipping_length, shipping_width, shipping_height)
      end

      private

      def dimension_display(length, width, height)
        builder = { L: clean_measurement(length),
                    W: clean_measurement(width),
                    H: clean_measurement(height) }

        builder.reject { |_k, measurement| measurement == '0' }
               .map { |dimension, measurement| "#{measurement}\" #{dimension}" }
               .join(' x ')
      end

      def clean_measurement(measurement)
        ActiveSupport::NumberHelper.number_to_rounded(measurement, precision: 2, strip_insignificant_zeros: true) ||
          '0'
      end
    end
  end
end
