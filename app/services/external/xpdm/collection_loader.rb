module External
  module XPDM
    class CollectionLoader
      def base_arel
        External::XPDM::Collection.web_collection
      end

      def transformer_class
        Transform::Transformers::XPDM::Collection
      end

      def restart_id
        CatModels::ConceptCollection.where.not(concept_id: 3).maximum(:source_collection_id)
      end

      def transform(engine, arel)
        arel.preload(Transform::Transformers::XPDM::Collection.source_includes).in_batches(of: 10) do |collections|
          engine.transform_items(collections)
        end
      end
    end
  end
end
