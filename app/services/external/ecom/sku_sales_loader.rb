module External
  module ECOM
    # full approach for loading sku sales data from estage each day, once we have a full load as baseline:
    #
    #  - truncate sku_sales_incremental
    #  - load estage data for day/period, probably with look back window, into sku_sales_incremental
    #  - merge this data into sku_sales (master table)
    #  - run rollup on new data from sku_sales --> sku_sales_summary
    #
    # N.B. Only full load has been run so far
    # TODO CAT-1295 fully implement above daily process
    class SkuSalesLoader
      attr_reader :look_back_window

      def initialize(look_back_window = 3.days)
        @look_back_window = look_back_window
      end

      def base_arel
        External::ECOM::SkuSales
      end

      def transformer_class
        Transform::Transformers::ECOM::SkuSales
      end

      def transform(engine, arel)
        arel.in_batches { |batch| engine.transform_items(batch) }
      end
    end
  end
end
