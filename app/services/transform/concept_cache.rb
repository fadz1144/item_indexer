module Transform
  class ConceptCache
    def self.build
      new
    end

    def self.fetch(concept_id)
      Rails.configuration.transform_concept_cache.fetch(concept_id)
    end

    def initialize
      cache = ActiveSupport::Cache::MemoryStore.new

      CatModels::Concept.all.each do |concept|
        cache.write(concept.concept_id, concept)
      end

      Rails.configuration.transform_concept_cache = cache
    end
  end
end
