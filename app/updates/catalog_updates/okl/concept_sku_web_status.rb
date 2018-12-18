module CatalogUpdates
  module OKL
    class ConceptSkuWebStatus
      def arel
        CatModels::ConceptSku.where(concept_id: 3)
      end

      def update_statement
        <<~SQL
          web_status = case
                       when status_reason_cd is not null then 'Dropped'
                       when status = 'Active' then 'Active'
                       else 'Inactive'
                       end
        SQL
      end
    end
  end
end
