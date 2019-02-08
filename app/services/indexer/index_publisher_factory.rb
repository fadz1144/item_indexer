module Indexer
  class IndexPublisherFactory
    def self.publisher_for(type:, platform:, precache: true)
      indexer = IndexerFactory.build_indexer(factory_type: type, platform: platform)
      client = client(platform: platform)
      Indexer::IndexPublisher.new(indexer: indexer, client: client, precache: precache)
    end

    class << self
      private

      def client(platform:)
        raise ArgumentError, "pltaform not supported #{platform}" unless %i[es solr].include?(platform)
        client_class = "#{platform.upcase}::#{platform.to_s.upcase}Client".constantize
        client_class.new
      end
    end
  end
end
