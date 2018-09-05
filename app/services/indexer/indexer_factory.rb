module Indexer
  class IndexerFactory
    def self.build_indexer(factory_type:, platform: :es)
      raise ArgumentError, "platform not supported #{platform}" unless %i[es solr].include?(platform)

      serializer_class = "#{platform.upcase}::#{factory_type.to_s.titlecase}Serializer".constantize
      indexer_class = "Indexer::#{factory_type.to_s.titlecase}Indexer".constantize

      indexer_class.new(serializer_class: serializer_class)
    end
  end
end
