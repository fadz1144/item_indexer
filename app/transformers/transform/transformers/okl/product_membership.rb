module Transform
  module Transformers
    module OKL
      class ProductMembership < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuRevision'
        references :product, association: :concept_product
      end
    end
  end
end
