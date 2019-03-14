# clear inventory from CA concept skus where the sku is not sellable in CA
module CatalogUpdates
  module XPDM
    class NotSellableInCanada
      def arel
        CatModels::ConceptSku
          .joins(:sku)
          .where(canadian_sku_not_sellable_there)
      end

      def update_statement
        'total_avail_qty = 0, warehouse_avail_qty = 0, vdc_avail_qty = 0'
      end

      private

      def canadian_sku_not_sellable_there
        <<~SQL
              concept_skus.concept_id = 2
          and skus.available_in_ca_dist_cd is null
          and skus.ca_fulfillment_cd not in ('E', 'R')
          and skus.transferable_to_canada = false
          and concept_skus.total_avail_qty > 0
        SQL
      end
    end
  end
end
