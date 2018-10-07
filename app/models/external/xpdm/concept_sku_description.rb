module External
  module XPDM
    # = Concept Sku Description
    #
    # Model Concept Sku Description is not an ActiveRecord. Because skus have multiple description rows, this class
    # determines the correct record and attribute for each method.
    class ConceptSkuDescription < External::XPDM::ConceptItemDescription
      delegate :jda_desc, :pos_desc, to: :@item_master, allow_nil: true

      def initialize(descriptions)
        super
        @item_master = descriptions.find { |description| item_master?(description) }
      end

      private

      def item_master?(description)
        description.web_site_id == 'ALL' && description.language_cd == 'ALL' && description.country_cd == 'USA'
      end
    end
  end
end
