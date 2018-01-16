module Transform
  module Transformers
    module OKL
      class Brand < CatalogTransformer::Base
        source_name 'Inbound::OKL::BrandRevision'
      end
    end
  end
end
