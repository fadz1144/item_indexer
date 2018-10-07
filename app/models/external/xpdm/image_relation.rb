module External
  module XPDM
    class ImageRelation < External::XPDM::ItemRelation
      # this appears to be both Product and Sku, despite the rltn_type
      # some do have more than one row with data, but the site only seems to show one.
      default_scope { where(rltn_type: 'Product_WebImage_Reference') }
      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :image_relation

      # the digital asset is not currently used; it's a lookup table that is missing data
      # belongs_to :digital_asset, foreign_key: :item_code_name_cd, primary_key: :dgtl_asset_item_id,
      #                            inverse_of: :image_relation

      # foreign key item_code_name_cd is an Id prefixed with IMG_
      def image_asset_id
        item_code_name_cd&.delete('IMG_').to_i
      end

      def image_name
        parsed_image_file_name&.gsub(/\.\w{3,4}/, '') || "__MISSING__#{image_asset_id}"
      end

      private

      # sample value: IMG_1222641 || 12226413325694m.jpg
      def parsed_image_file_name
        return nil if item_code_name.nil?
        item_code_name.split(' || ').last
      end
    end
  end
end
