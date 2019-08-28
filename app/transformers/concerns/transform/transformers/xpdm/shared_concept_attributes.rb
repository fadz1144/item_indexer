module Transform
  module Transformers
    module XPDM
      module SharedConceptAttributes
        extend ActiveSupport::Concern

        included do
          attribute :web_offer_date, source_name: :web_offer_dt
          attribute :web_enable_date, source_name: :web_enable_dt
        end
      end
    end
  end
end
