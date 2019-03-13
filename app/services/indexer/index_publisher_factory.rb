module Indexer
  class IndexPublisherFactory
    def self.publisher_for(type:, precache: true)
      indexer = IndexerFactory.build_indexer(factory_type: type)
      Indexer::IndexPublisher.new(core: type, indexer: indexer, precache: precache)
    end
  end
end
