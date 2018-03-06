module Inbound
  module Messages
    module OKL
      class Sku < CatalogMessage::Base
        model 'Inbound::OKL::SkuRevision'

        has_one :shipping, source_name: :sku_shipping
        has_one :dimensions, source_name: :sku_dimensions, attribute_mapping: SOURCE_STAMPS_MAPPING
        has_one :state, source_name: :sku_states
        has_one :inventory, source_name: :sku_inventory
        has_many :images, source_name: :sku_images
        has_many :sku_attributes, source_name: :sku_additional_attributes

        attribute_mapping({ source_sku_id: 'okl_sku_id',
                            source_product_id: 'product_id' }.merge(SOURCE_STAMPS_MAPPING))
        propagate_attributes 'sku_id'

        def item_id
          data_attributes['sku_id']
        end
      end
    end
  end
end
