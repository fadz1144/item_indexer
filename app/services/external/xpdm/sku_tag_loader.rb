module External
  module XPDM
    class SkuTagLoader
      include External::XPDM::ParentTagLoader

      def base_arel
        External::XPDM::CMTag.joins(:item).merge(External::XPDM::Sku.beyond_sku)
      end

      private

      def fetch_indexed_parents(ids)
        CatModels::Sku.where(sku_id: ids).index_by(&:sku_id)
      end
    end
  end
end
