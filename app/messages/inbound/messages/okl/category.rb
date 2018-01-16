module Inbound
  module Messages
    module OKL
      class Category < CatalogMessage::Base
        model 'Inbound::OKL::CategoryRevision'
        attribute_mapping({ source_category_id: 'category_id' }.merge(SOURCE_STAMPS_MAPPING))

        def item_id
          data_attributes['category_id']
        end
      end
    end
  end
end
