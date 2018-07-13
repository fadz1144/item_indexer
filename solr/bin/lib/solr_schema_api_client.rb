require 'json'
require 'net/http'

class SolrSchemaApiClient
  # eg solr_base_uri => 'http://localhost:8983/solr/'
  #    core => 'product'
  def initialize(solr_base_uri, core)
    @solr_base_url = solr_base_uri
    @core = core

    @schema_endpoint = "#{solr_base_uri}#{core}/schema"
  end

  # eg
  # fields_to_add => {"name":"name", "type":"text_general", "multiValued":false, "stored":true}}
  # can also be:
  # fields_to_add => [{"name":"name", "type":"text_general", "multiValued":false, "stored":true}, ...]
  def add_fields(fields_to_add)
    data = { 'add-field' => fields_to_add }.to_json

    url = URI.parse(@schema_endpoint)
    http = Net::HTTP.new(url.host, url.port)
    response, body = http.post(url.path, data, 'Content-type' => 'application/json')

    unless response.is_a? Net::HTTPSuccess
      puts response.inspect
      raise 'Bad Response'
    end
    JSON.parse(body, symbolize_names: true) if body
  end
end
