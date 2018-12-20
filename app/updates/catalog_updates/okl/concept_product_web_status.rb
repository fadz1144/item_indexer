module CatalogUpdates
  module OKL
    class ConceptProductWebStatus
      def arel
        CatModels::ConceptProduct
          .where(concept_id: 3)
          .where("coalesce(web_status, 'oski') not in ('Active', 'Inactive')")
      end

      def update_statement
        'web_status = initcap(status)'
      end
    end
  end
end
