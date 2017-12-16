module Transform
  module Transformers
    module OKL
      class Product < CatalogTransformer::Base
        source_name 'Inbound::OKL::ProductRevision'
        exclude :membership_hash

        references :brand, association: :concept_brand
        references :category, association: :concept_category
      end
    end
  end
end
