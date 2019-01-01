module Transform
  module Transformers
    module XPDM
      module SharedConceptReferences
        extend ActiveSupport::Concern

        included do
          references :concept
          references :concept_vendor
          references :concept_brand
        end
      end
    end
  end
end
