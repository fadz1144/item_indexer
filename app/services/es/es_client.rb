module ES
  class ESClient
    attr_reader :client

    def initialize
      dev_search_index = 'https://search-upc-dev-2bhighuzv3fnbmyh42gmjy7aby.us-east-1.es.amazonaws.com'
      endpoint = ENV['ELASTICSEARCH_HOST'] || dev_search_index

      Rails.logger.info "Elastic search endpoint is set to: #{endpoint}"

      @client = build_client(endpoint)
    end

    def publish_items(indexer, items)
      json = items.map { |item| index_hash_for_item(indexer, item) }.compact
      bulk body: json
    end

    def build_client(endpoint)
      has_creds = ENV['ES_AWS_ACCESS_KEY_ID'].present? && ENV['ES_AWS_SECRET_ACCESS_KEY'].present?
      if has_creds
        credentialed_client(endpoint)
      else
        Elasticsearch::Client.new(host: endpoint, port: 9200)
      end
    end

    def credentialed_client(endpoint)
      Elasticsearch::Client.new(url: endpoint) do |f|
        f.request :aws_signers_v4,
                  credentials: Aws::Credentials.new(ENV['ES_AWS_ACCESS_KEY_ID'],
                                                    ENV['ES_AWS_SECRET_ACCESS_KEY']),
                  service_name: 'es',
                  region: 'us-east-1'
        f.adapter Faraday.default_adapter
      end
    end

    private

    def index_hash_for_item(indexer, item)
      { index: { _index: index_root, _type: indexer.index_type, _id: item.id, data: indexer.raw_json(item) } }
    end

    def bulk(arguments)
      response = @client.bulk(arguments)
      response
    end

    def index_root
      'catalog'
    end
  end
end
