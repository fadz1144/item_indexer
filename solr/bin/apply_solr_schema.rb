require_relative 'lib/solr_schema_api_client'
require_relative '../../app/serializers/solr/field_definition'
require_relative '../../app/serializers/solr/product_core_fields'

# This needs to REMAIN safe to run against a live SOLR index (re-runnable, non-destructive)
# This will be run whenever we reindex all products (ie daily)
# Having this called will prevent our indexes from drifting.

# TODO: need to parameterize this
solr_base_url = ENV['SOLR_ENDPOINT'] || 'http://localhost:8983/solr/'
core = ENV['SOLR_CORE'] || 'product'

solr_client = SolrSchemaApiClient.new(solr_base_url, core)

all_fields = SOLR::ProductCoreFields.all_fields

all_fields.map(&:solr_field_definition).each do |f|
  result = solr_client.add_fields(f)
  puts "Added field #{f} #{result.to_s.strip}"
rescue
  puts "Unable to add field #{f} or perhaps it already exists"
end
