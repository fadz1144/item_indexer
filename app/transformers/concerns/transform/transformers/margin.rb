module Transform
  module Transformers
    module Margin
      def margin_amount
        return nil unless price&.nonzero? && cost&.nonzero?
        price - cost if price > cost
      end

      def margin_percent
        return nil unless margin_amount&.nonzero?
        margin_amount / price
      end
    end
  end
end
