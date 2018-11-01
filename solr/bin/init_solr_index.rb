require_relative 'lib/solr_schema_api_client'
require_relative '../../app/serializers/solr/product_core_fields'

# TODO: need to parameterize this
solr_base_url = ENV['SOLR_ENDPOINT'] || 'http://localhost:8983/solr/'
core = ENV['SOLR_CORE'] || 'product'

solr_client = SolrSchemaApiClient.new(solr_base_url, core)

all_fields = SOLR::ProductCoreFields.all_fields

all_fields.map(&:solr_field_definition).each do |f|
  result = solr_client.add_fields(f)
  puts result
rescue
  puts "Unable to add field #{f} or perhaps it already exists"
end
