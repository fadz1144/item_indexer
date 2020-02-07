module External
  module XPDM
    # = Image
    #
    # The Image class is a non-active model that is intersection of the ImageRelation plus the alt image indexes.
    class Image
      include External::XPDM::TransformerNonActiveRecordModel

      # products either don't have alt images or the current data access does not include that, so products would just
      # instantiate an image via the contructor
      def self.from_sku(sku)
        return [] if sku.image_relation.nil?
        [new(sku.image_relation)] +
          sku.alt_image_suffixes.map { |suffix| new(sku.image_relation, suffix) }
      end

      # the transformation batch records errors with the primary_key, so pretend this class has one
      def self.primary_key
        :image_asset_id
      end

      delegate :image_asset_id, to: :@image_relation

      def initialize(image_relation, alt_index = nil)
        @image_relation = image_relation
        @alt_index = alt_index
      end

      def resource_name
        @alt_index.present? ? "#{@image_relation.image_name}__#{@alt_index}" : @image_relation.image_name
      end

      def image_url
        "https://s7d2.scene7.com/is/image/BedBathandBeyond/#{resource_name}"
      end

      def alt_index
        @alt_index&.to_i || 0
      end
    end
  end
end
