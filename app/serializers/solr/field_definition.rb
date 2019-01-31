module SOLR
  class FieldDefinition
    # this is not the full list, just the only ones we use; need to add it here to pass it to SOLR
    VALID_OPTIONS = %i[name type indexed stored multiValued].freeze

    def initialize(name, options)
      @options = { name: name }.merge(options)
    end

    def solr_field_definition
      @options.slice(*VALID_OPTIONS)
    end

    def name
      @options.fetch(:name).to_sym
    end

    def source_name
      @options.fetch(:source_name, name).to_sym
    end
  end
end
