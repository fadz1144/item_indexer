module SOLR
  class SOLRClient
    attr_reader :client

    def initialize(core = 'product')
      dev_search_index = 'http://localhost:8983/solr/'
      base_endpoint = Rails.configuration.settings['solr']['endpoint'] || dev_search_index
      actual_solr_core = ENV['SOLR_CORE'] || core
      endpoint = "#{base_endpoint}#{actual_solr_core}"

      Rails.logger.info "SOLR endpoint is set to: #{endpoint}"

      @client = build_client(endpoint)
    rescue => exception
      SOLR.notify_and_exit(exception, "cannot instantiate Solr client for endpoint '#{endpoint}'")
    end

    def ping
      status = @client.head('admin/ping').response[:status]
      raise "status #{status}" if status != 200
    rescue => exception
      SOLR.notify_and_exit(exception, 'failed ping of Solr client')
    end

    def publish_items(indexer, items)
      @client.add items_to_documents(indexer, items)
      @client.commit
    end

    def items_to_documents(indexer, items)
      items.map { |item| index_hash_for_item(indexer, item) }.compact
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
