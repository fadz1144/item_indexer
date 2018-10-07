module External
  module XPDM
    # = Digital Asset
    #
    # Update: This table is missing value info for about 165k skus. The join table has all the information required,
    # so this table is no longer going to be included in the transformation. Both sides of the association have been
    # commented out.
    #
    # Connected to the main table via Image Relation, this table holds the distinct part of the image url. For example,
    # if the image url is the following: https://s7d2.scene7.com/is/image/BedBathandBeyond/64181244535582p,
    # then the image_file_name here would be 64181244535582p.jpg.
    #
    class DigitalAsset < External::XPDM::Base
      self.table_name = 'pdm_lu_dgtl_asset'
      self.primary_key = 'dgtl_asset_item_id'
      # has_one :image_relation, foreign_key: :item_code_name_cd, primary_key: :dgtl_asset_item_id, dependent: :destroy,
      #                          inverse_of: :digital_asset
    end
  end
end
