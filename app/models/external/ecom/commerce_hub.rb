module External
  module ECOM
    class CommerceHub < External::ECOM::Base
      self.table_name = 'comhub_feed'
      self.primary_key = :upc
      extend External::DateComparisonQueryBuilders

      def self.updates_since(datetime)
        date_gteq(datetime, :comhub_mod_dt)
      end

      def gtin
        upc.to_i
      end
    end
  end
end
