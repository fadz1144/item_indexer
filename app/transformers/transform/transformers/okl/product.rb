module Transform
  module Transformers
    module OKL
      class Product < CatalogTransformer::Base
        source_name 'Inbound::OKL::ProductRevision'
        decorator_name 'Transform::Transformers::OKL::Decorators::ProductConceptProductDecorator'
        exclude :membership_hash

        references :vendor, association: :concept_vendor
        references :brand, association: :concept_brand
        references :category, association: :concept_category
      end
    end
  end
end
