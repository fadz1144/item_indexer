module External
  module XPDM
    # = Concept Description
    #
    # Model Concept Description is not an ActiveRecord. Because products have multiple description rows, this class
    # determines the correct record and attribute for each method.
    class ConceptItemDescription
      delegate :mstr_prod_desc, :mstr_shrt_desc, :mstr_web_desc, :prod_desc, :vdr_web_prod_desc, :source_updated_at,
               to: :@default, allow_nil: true

      def initialize(descriptions)
        @default = descriptions.first { |description| default?(description) } || descriptions.first
      end

      private

      def default?(description)
        description.web_site_id == 'ALL' && description.language_cd == 'ALL' && description.country_cd == 'ALL'
      end
    end
  end
end
