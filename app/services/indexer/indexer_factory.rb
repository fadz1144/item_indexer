module Indexer
  class IndexerFactory
    def self.build_indexer(factory_type:)
      indexer_class = "Indexer::#{factory_type.to_s.titlecase}Indexer".constantize
      indexer_class.new
    end
  end
end
