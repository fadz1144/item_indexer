module CatalogUpdates
  class NullSkuVendors
    def arel
      CatModels::Sku.where(vendor_id: nil)
    end

    def execute_update(sku_ids)
      CatModels::Sku.connection.execute(update_statement(sku_ids.compact))
    end

    private

    def update_statement(sku_ids)
      <<~SQL
        update skus
        set vendor_id = cv.vendor_id
        from concept_skus cs, concept_vendors cv
        where cs.sku_id = skus.sku_id
          and cv.concept_vendor_id = cs.concept_vendor_id
          and skus.sku_id in (#{sku_ids.join(',')});
      SQL
    end
  end
end
