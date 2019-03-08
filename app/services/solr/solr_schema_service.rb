module SOLR
  class SolrSchemaService
    GREEN = "\e[32m".freeze
    RED = "\e[31m".freeze
    DEFAULT = "\e[0m".freeze

    # This needs to REMAIN safe to run against a live SOLR index (re-runnable, non-destructive)
    # This will be run whenever we reindex all products (ie daily)
    # Having this called will prevent our indexes from drifting.

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Rails/Output
    def apply_solr_schema(solr_base_url: 'http://localhost:8983/solr/', core: 'product')
      solr_client = SOLR::SolrSchemaApiClient.new(solr_base_url, core)

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
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Rails/Output
  end
end
