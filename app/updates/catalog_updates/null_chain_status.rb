module CatalogUpdates
  class NullChainStatus
    def arel
      CatModels::Sku.where(chain_status: nil)
    end

    def update_statement
      "chain_status = 'Unknown'"
    end
  end
end
