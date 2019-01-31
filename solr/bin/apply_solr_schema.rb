require_relative 'lib/solr_schema_api_client'
require_relative '../../app/serializers/solr/field_definition'
require_relative '../../app/serializers/solr/product_core_fields'
GREEN = "\e[32m".freeze
RED = "\e[31m".freeze
DEFAULT = "\e[0m".freeze

# This needs to REMAIN safe to run against a live SOLR index (re-runnable, non-destructive)
# This will be run whenever we reindex all products (ie daily)
# Having this called will prevent our indexes from drifting.

# TODO: need to parameterize this
solr_base_url = ENV['SOLR_ENDPOINT'] || 'http://localhost:8983/solr/'
core = ENV['SOLR_CORE'] || 'product'

solr_client = SolrSchemaApiClient.new(solr_base_url, core)

all_fields = SOLR::ProductCoreFields.all_fields

existing = []
all_fields.each do |f|
  response = solr_client.add_field(f.solr_field_definition)

  if response.success?
    puts "#{GREEN}[ADD]#{DEFAULT} #{f.name}: #{f.solr_field_definition}"
  elsif response.field_exists?
    existing << f.name
  else
    puts "#{RED}[ERROR]#{DEFAULT} #{f.name}: #{response.error_messages.join('; ')}"
  end
end

puts "The following fields already existed: #{existing.join(', ')}" unless existing.empty?
