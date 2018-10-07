module External
  module ECOM
    # = Item
    #
    # The items table in the ECOMADMIN database has skus only.
    class Item < External::ECOM::Base
      self.primary_key = :sku
      has_one :item_picture, foreign_key: :photo_id, primary_key: :photo_id, dependent: :destroy, inverse_of: :item

      # use this scope to pull in the zoom indexes in a single query
      scope :alt_image_count_only, -> { joins(:item_picture).select('items.sku, item_pictures.zoom_indexes') }
    end
  end
end
