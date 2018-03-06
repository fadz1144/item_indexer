module Transform
  module Transformers
    module OKL
      class ConceptSkuAttribute < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuAttributeRevision'

        exclude :concept_sku_id

        module Decorations
          def concept_id
            CONCEPT_ID
          end
        end
      end
    end
  end
end
