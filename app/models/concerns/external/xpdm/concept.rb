module External
  module XPDM
    module Concept
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
