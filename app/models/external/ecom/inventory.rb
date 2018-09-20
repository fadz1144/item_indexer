module External
  module ECOM
    # = Inventory
    #
    # The Inventory table is keyed by sku Id as SKU. The last updated stamp is row_xng_dt.
    class Inventory < External::ECOM::Base
      extend External::DateComparisonQueryBuilders
      self.table_name = 'dom_inventory'
      self.primary_key = :sku

      def self.updates_since(datetime)
        date_gteq(datetime, :row_xng_dt)
      end

      def warehouse?
        inv_source == 'W'
      end

      def vdc?
        inv_source == 'V'
      end
    end
  end
end
