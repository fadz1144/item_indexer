module CatalogUpdates
  module XPDM
    class SkuVDC
      def arel
        CatModels::Sku.where(brand: 13_611).where("date(updated_at) = '2018-12-11'")
      end

      def execute_update(sku_ids)
        filtered_ids = false_positive_sku_ids(sku_ids.compact)
        CatModels::Sku.where(sku_id: filtered_ids)
                      .update_all(vdc_sku: false) # rubocop:disable Rails/SkipsModelValidations
      end

      private

      def false_positive_sku_ids(sku_ids)
        sku_ids - vdc_sku_ids(sku_ids)
      end

      def vdc_sku_ids(sku_ids)
        External::XPDM::Logistics.where(pdm_object_id: sku_ids)
                                 .where("PDM_ITEM_LGSTCS_INFO.vdc_ind in ('Y', 'Yes')")
                                 .pluck(:pdm_object_id)
      end
    end
  end
end
