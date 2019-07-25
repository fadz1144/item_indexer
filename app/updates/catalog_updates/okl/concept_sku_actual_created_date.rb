module CatalogUpdates
  module OKL
    class ConceptSkuActualCreatedDate
      def arel
        CatModels::ConceptSku.where(concept_id: 3)
      end

      def update_statement
        <<~SQL
          actual_created_date = source_created_at
        SQL
      end
    end
  end
end
