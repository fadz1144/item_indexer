module External
  module XPDM
    module Concept
      CONCEPT_ID_BEDBATHANDBEYOND = 1
      CONCEPT_ID_BEDBATHANDBEYOND_CANADA = 2
      CONCEPT_ID_BUY_BUY_BABY = 4

      def concept
        Transform::ConceptCache.fetch(concept_id)
      end

      def concept_id
        case web_site_cd
        when 'BBBY' then
          1
        when 'CA' then
          2
        when 'BABY' then
          4
        else
          raise "Invalid web_site_cd: #{web_site_cd}"
        end
      end
    end
  end
end
