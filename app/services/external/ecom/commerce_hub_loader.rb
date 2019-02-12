module External
  module ECOM
    class CommerceHubLoader
      attr_reader :look_back_window

      def initialize(look_back_window = 3.days)
        @look_back_window = look_back_window
      end

      def base_arel
        External::ECOM::CommerceHub
      end

      def transformer_class
        Transform::Transformers::ECOM::CommerceHub
      end

      def transform(engine, arel)
        arel.in_batches { |batch| engine.transform_items(batch) }
      end
    end
  end
end
