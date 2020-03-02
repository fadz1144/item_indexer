module External
  module XPDM
    class Product < External::XPDM::Item
      with_options foreign_key: :pdm_object_id, primary_key: :pdm_object_id, dependent: :destroy,
                   inverse_of: :product do
        has_many :bbby_site_navigations
        has_many :ca_site_navigations
        has_many :baby_site_navigations
      end

      with_options primary_key: :pdm_object_id, foreign_key: :sku do
        has_one :item_picture, -> { alt_image_count_only }, class_name: 'External::ECOM::Item'
      end

      # this is not a default scope, because it's not needed when in_batches fetches by id
      # for all other queries, it does need to be included
      scope :web_product, -> { where(pdm_object_type: %w[WebProduct WEBPRODUCT]) }

      # subset for testing
      def self.modulo(divisor = 10, modulus = 1)
        p = arel_table.name
        where("mod(#{p}.pdm_object_id, #{divisor}) = #{modulus}")
      end

      has_many :product_memberships, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, dependent: :destroy

      def concept_products
        @concept_products ||= External::XPDM::ConceptProduct.from_parent(self)
      end

      def alt_image_suffixes
        @alt_image_suffixes ||= item_picture&.zoom_indexes&.split(',') || []
      end
    end
  end
end
