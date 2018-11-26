module External
  module XPDM
    class Sku < External::XPDM::Item
      extend External::DateComparisonQueryBuilders
      # this is not a default scope, because it's not needed when in_batches fetches by id
      # for all other queries, it does need to be included
      scope :beyond_sku, -> { where(pdm_object_type: %w[BeyondSKU BEYONDSKU]) }
      include External::XPDM::DimensionsAccessors

      with_options primary_key: :pdm_object_id, foreign_key: :pdm_object_id, dependent: :destroy do
        has_many :assembly_dimensions, class_name: 'External::XPDM::AssemblyDimensions'
        has_many :package_dimensions, class_name: 'External::XPDM::PackageDimensions'
        has_many :web_prices, class_name: 'External::XPDM::WebPrice'
        has_many :web_costs, class_name: 'External::XPDM::WebCost'
      end

      has_many :product_memberships, class_name: 'External::XPDM::ProductMembershipLocal', primary_key: :pdm_object_id,
                                     foreign_key: :item_code_name_cd, dependent: :destroy

      with_options primary_key: :pdm_object_id, foreign_key: :sku do
        has_one :item_picture, -> { alt_image_count_only }, class_name: 'External::ECOM::Item'
        has_one :inventory, class_name: 'External::ECOM::Inventory', dependent: :restrict_with_exception
      end

      delegate :pmry_vdr_part_modl_num, to: :item_vendor, allow_nil: true

      # subset for testing
      def self.product_modulo(divisor = 10, modulus = 1)
        pm = External::XPDM::ProductMembershipLocal.arel_table.name
        joins(:product_memberships).where("mod(#{pm}.pdm_object_id, #{divisor}) = #{modulus}")
      end

      def concept_skus
        @concept_skus ||= External::XPDM::ConceptSku.from_parent(self)
      end

      def alt_image_suffixes
        @alt_image_suffixes ||= item_picture&.zoom_indexes&.split(',') || []
      end

      def image_count
        image_relation.nil? ? 0 : alt_image_suffixes.size + 1
      end

      def bbby_site_navigation
        product_site_navigation(:bbby_site_navigation)
      end

      def ca_site_navigation
        product_site_navigation(:ca_site_navigation)
      end

      def baby_site_navigation
        product_site_navigation(:baby_site_navigation)
      end

      private

      def product_site_navigation(association_name)
        product_memberships.map(&:product).map(&association_name).compact.first
      end
    end
  end
end
