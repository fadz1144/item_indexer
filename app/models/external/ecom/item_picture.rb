module External
  module ECOM
    class ItemPicture < External::ECOM::Base
      self.primary_key = :photo_id
      belongs_to :item
    end
  end
end
