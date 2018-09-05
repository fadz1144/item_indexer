module SOLR
  class SOLRClient
    attr_reader :client

    def initialize(core = 'product')
      dev_search_index = 'http://localhost:8983/solr/'
      host = ENV['SOLR_HOST'] || dev_search_index
      actual_solr_core = ENV['SOLR_CORE'] || core
      endpoint = "#{host}#{actual_solr_core}"

      Rails.logger.info "SOLR endpoint is set to: #{endpoint}"

      @client = build_client(endpoint)
    end

    def publish_items(indexer, items)
      documents = items.map { |item| index_hash_for_item(indexer, item) }.compact
      @client.add documents
      @client.commit
    end

    private

    def index_hash_for_item(indexer, item)
      indexer.raw_json(item)
    rescue => e
      Rails.logger.error("Unable to generate index hash for #{item.id}.  Reason: #{e.message}")
      Rails.logger.error e.backtrace.join("\n")
      nil
    end

    def build_client(endpoint)
      RSolr.connect(url: endpoint)
    end
  end
end