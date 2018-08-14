module External
  module XPDM
    class ProductLoader
      def base_arel
        External::XPDM::Product.web_product
      end

      def transformer_class
        Transform::Transformers::XPDM::Product
      end

      def restart_id
        CatModels::ConceptProduct.where.not(concept_id: 3).maximum(:source_product_id)
      end

      def transform(engine, arel)
        arel.preload(Transform::Transformers::XPDM::Product.source_includes).in_batches do |products|
          engine.transform_items(products)
        end
      end
    end
  end
end
