module CatalogUpdates
  class NullConceptProductVendors
    def arel
      CatModels::ConceptProduct.where(concept_vendor_id: nil)
    end

    def execute_update(concept_product_ids)
      CatModels::ConceptProduct.connection.execute(update_statement(concept_product_ids.compact))
    end

    private

    def update_statement(concept_product_ids)
      <<~SQL
        update concept_products
        set concept_vendor_id = cv.concept_vendor_id
        from products p, concept_vendors cv
        where concept_products.product_id = p.product_id
          and cv.concept_id = concept_products.concept_id
          and cv.vendor_id = p.vendor_id
          and concept_products.concept_product_id in (#{concept_product_ids.join(',')})
      SQL
    end
  end
end
