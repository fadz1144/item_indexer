module Inbound
  module Messages
    module OKL
      class Product < CatalogMessage::Base
        model 'Inbound::OKL::ProductRevision'
        attribute_mapping({ source_product_id: 'product_id' }.merge(SOURCE_STAMPS_MAPPING))

        def item_id
          data_attributes['product_id']
        end
      end
    end
  end
end
