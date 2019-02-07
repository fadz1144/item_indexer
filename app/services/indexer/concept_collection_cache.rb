module Indexer
  class ConceptCollectionCache
    class << self
      delegate :clear, to: :cache

      def build
        new
      end

      def fetch(concept_id, collection_id)
        cache.fetch(to_key(concept_id, collection_id)) do
          CatModels::ConceptCollection.where(concept_id: concept_id, collection_id: collection_id).first
        end
      end

      def to_key(concept_id, collection_id)
        [concept_id, collection_id]
      end

      private

      def cache
        unless config.respond_to?(:indexer_concept_collection_cache)
          config.indexer_concept_collection_cache = ActiveSupport::Cache::MemoryStore.new
        end
        config.indexer_concept_collection_cache
      end

      def config
        Rails.configuration
      end
    end

    def initialize
      self.class.clear

      concept_collections.each do |concept_collection|
        key = ConceptCollectionCache.to_key(concept_collection.concept_id, concept_collection.collection_id)
        self.class.send(:cache).write(key, to_h(concept_collection))
      end
    end

    private

    def concept_collections
      CatModels::ConceptCollection.all
    end

    def to_h(concept_collection)
      {
        name: concept_collection.name,
        source_collection_id: concept_collection.source_collection_id
      }
    end
  end
end
