module CatalogUpdates
  class ChainStatus
    def self.all_models
      [CatModels::Sku]
    end

    def self.each
      all_models.each { |m| yield new(m) }
    end

    def initialize(model)
      @model = model
    end

    def arel
      @model.where(chain_status: %w[A D I N P U])
    end

    def update_statement
      <<~SQL
        chain_status = case chain_status
                            when 'A' then 'Active'
                            when 'D' then 'Discontinued'
                            when 'I' then 'Inactive'
                            when 'N' then 'Dropped'
                            when 'P' then 'To be Purged'
                            else 'Unknown' end
      SQL
    end
  end
end
