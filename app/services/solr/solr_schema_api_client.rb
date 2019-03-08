require 'json'
require 'net/http'

module SOLR
  class SolrSchemaApiClient
    # eg solr_base_uri => 'http://localhost:8983/solr/'
    #    core => 'product'
    def initialize(solr_base_uri, core)
      @solr_base_url = solr_base_uri
      @core = core

      @schema_endpoint = "#{solr_base_uri}#{core}/schema"
    end

    # Example Field Definition:
    # https://lucene.apache.org/solr/guide/7_6/defining-fields.html#example-field-definition
    def add_field(field)
      data = { 'add-field' => field }.to_json

      url = URI.parse(@schema_endpoint)
      http = Net::HTTP.new(url.host, url.port)
      Response.new(http.post(url.path, data, 'Content-type' => 'application/json'))
    end

    class Response
      def initialize(response)
        @response = response
        @json = JSON.parse(response.body)
      end

      def success?
        @response.is_a? Net::HTTPSuccess
      end

      def error?
        !success? && !field_exists?
      end

      def status
        @json.dig('responseHeader', 'status')
      end

      def error_messages
        @json.dig('error', 'details').flat_map { |detail| detail['errorMessages'] }
      end

      def field_exists?
        error_messages.any? { |s| /Field '\w+' already exists/.match? s }
      end
    end
  end
end
