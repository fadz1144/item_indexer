module Transform
  module Transformers
    module Margin
      def margin_amount
        return nil unless price.present? && cost.present? && price > cost
        price - cost
      end

      def margin_percent
        return nil unless margin_amount.present? && !price.zero?
        margin_amount / price
      end
    end
  end
end
