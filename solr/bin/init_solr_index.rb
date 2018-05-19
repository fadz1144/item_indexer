require_relative 'lib/solr_schema_api_client'
require_relative '../../app/serializers/solr/product_core_fields'

# TODO: need to parameterize this
solr_base_url = ENV['SOLR_BASE_URL'] || 'http://localhost:8983/solr/'
core = ENV['SOLR_CORE'] || 'product'

solr_client = SolrSchemaApiClient.new(solr_base_url, core)

all_fields = SOLR::ProductCoreFields.all_fields

result = solr_client.add_fields(all_fields)

puts result
