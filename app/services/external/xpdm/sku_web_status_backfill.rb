module External
  module XPDM
    class SkuWebStatusBackfill < External::XPDM::ProductWebStatusBackfill
      private

      def model
        External::XPDM::Sku.beyond_sku
      end

      def load_indexed_targets(pdm_object_ids)
        CatModels::Sku.includes(:brand, :vendor, concept_skus: %i[concept concept_brand concept_vendor])
                      .where(sku_id: pdm_object_ids)
                      .index_by(&:sku_id)
      end
    end
  end
end
