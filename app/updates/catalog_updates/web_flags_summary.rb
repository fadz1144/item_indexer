module CatalogUpdates
  class WebFlagsSummary
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
      @model.where.not(web_status: nil)
    end

    def update_statement
      <<~SQL
        web_flags_summary = case web_status
                            when 'Active' then 'Live on Site'
                            when 'In Progress' then 'In Workflow'
                            else web_status end
      SQL
    end
  end
end
