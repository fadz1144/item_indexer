module CatalogUpdates
  class NullWebFlagsSummary
    def self.all_models
      [CatModels::ConceptSku, CatModels::Sku, CatModels::ConceptProduct, CatModels::Product]
    end

    def self.each
      all_models.each { |m| yield new(m) }
    end

    def initialize(model)
      @model = model
    end

    def arel
      @model.where(web_flags_summary: nil)
    end

    def update_statement
      <<~SQL
        web_flags_summary = case web_status
                            when '#{CatModels::Constants::SystemStatus::ACTIVE}'
                              then '#{CatModels::Constants::WebFlagsSummary::LIVE_ON_SITE}'
                            when '#{CatModels::Constants::SystemStatus::INACTIVE}'
                              then '#{CatModels::Constants::WebFlagsSummary::IN_WORKFLOW}'
                            else '#{CatModels::Constants::WebFlagsSummary::SUSPENDED}' end
      SQL
    end
  end
end
