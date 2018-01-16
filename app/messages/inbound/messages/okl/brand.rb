module Inbound
  module Messages
    module OKL
      class Brand < CatalogMessage::Base
        model 'Inbound::OKL::BrandRevision'
        attribute_mapping({ source_brand_id: 'brand_id' }.merge(SOURCE_STAMPS_MAPPING))

        def item_id
          data_attributes['brand_id']
        end
      end
    end
  end
end
