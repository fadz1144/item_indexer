module Transform
  module Transformers
    module XPDM
      module SharedConceptMethods
        extend ActiveSupport::Concern

        def web_offered
          web_offer_ind == 'Y'
        end

        def web_disabled
          web_dsable_ind == 'Y'
        end
      end
    end
  end
end
