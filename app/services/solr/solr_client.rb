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
      documents, items_to_errors = items_to_documents(indexer, items)
      @client.add documents
      @client.commit
      items_to_errors
    end

    def items_to_documents(indexer, items)
      items_to_errors = {}
      documents = items.map do |item|
        json = index_hash_for_item(indexer, item)
        items_to_errors[item] = json if error?(json)
        error?(json) ? nil : json
      end.compact
      [documents, items_to_errors]
    end

    private

    def index_hash_for_item(indexer, item)
      indexer.raw_json(item)
    rescue => e
      Rails.logger.error("Unable to generate index hash for #{item.id}.  Reason: #{e.message}")
      Rails.logger.error e.backtrace.join("\n")
      { error: e.class.name, message: e, backtrace: e.backtrace }
    end

    def error?(index_hash_for_item)
      index_hash_for_item.include?(:error)
    end

    def build_client(endpoint)
      RSolr.connect(url: endpoint)
    end
  end
end
