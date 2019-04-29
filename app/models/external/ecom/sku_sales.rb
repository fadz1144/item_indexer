module External
  module ECOM
    class SkuSales < External::ECOM::Base
      self.table_name = 'ct_summary_sku_sales'
      self.primary_keys = :sku, :order_dt, :origin_cd, :reg_order_flag
      extend External::DateComparisonQueryBuilders

      def self.updates_since(datetime)
        date_gteq(datetime, :row_xing_dt)
      end
    end
  end
end
