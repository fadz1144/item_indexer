module External
  module XPDM
    class ProductTagLoader
      include External::XPDM::ParentTagLoader

      def base_arel
        External::XPDM::CMTag.joins(:item).merge(External::XPDM::Product.web_product)
      end

      private

      def fetch_indexed_parents(ids)
        CatModels::Product
          .eager_load(:concept_products)
          .merge(CatModels::ConceptProduct.where(concept_id: 1, source_product_id: ids))
          .index_by { |p| p.concept_products.first.source_product_id }
      end
    end
  end
end
