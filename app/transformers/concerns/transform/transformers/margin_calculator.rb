module Transform
  module Transformers
    module MarginCalculator
      def calculate_margin(target)
        if target.margin_determinable?
          target.margin_amount = target.retail_price - target.cost
          target.margin_percent = target.retail_price.zero? ? nil : target.margin_amount / target.retail_price
        else
          target.margin_amount = nil
          target.margin_percent = nil
        end
      end
    end
  end
end
