module CatalogUpdates
  class NullProductVendors
    def arel
      CatModels::Product.where(vendor_id: nil)
    end

    def execute_update(product_ids)
      CatModels::Product.connection.execute(update_statement(product_ids.compact))
    end

    private

    def update_statement(product_ids)
      <<~SQL
        update products
        set vendor_id = pv.vendor_id
        from (select distinct pm.product_id, s.vendor_id
              from product_memberships pm
              join skus s on pm.sku_id = s.sku_id
              where pm.product_id in (#{product_ids.join(',')})) pv
        where products.product_id = pv.product_id
      SQL
    end
  end
end
