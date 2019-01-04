module External
  module ECOM
    class CommerceHubLoader
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
