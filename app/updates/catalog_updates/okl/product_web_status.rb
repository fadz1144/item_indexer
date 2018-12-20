module CatalogUpdates
  module OKL
    class ProductWebStatus
      def self.each
        %w[Active Inactive].each { |status| yield new(status) }
      end

      def initialize(status)
        @status = status
      end

      def arel
        CatModels::Product
          .joins(:concept_products).merge(CatModels::ConceptProduct.where(concept_id: 3, web_status: @status))
          .where("coalesce(products.web_status, 'oski') != 'Active'")
      end

      def update_statement
        "web_status = '#{@status}'"
      end
    end
  end
end
