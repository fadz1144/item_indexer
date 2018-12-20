module External
  module XPDM
    class Item < External::XPDM::Base
      self.table_name = 'pdm_item_prod_info'
      include External::XPDM::MerchandisingTreeNodeAssociations
      attribute :pattern_name, :xpdm_string

      with_options foreign_key: :pdm_object_id, dependent: :destroy, inverse_of: :item do
        has_one :item_vendor
        has_one :compliance
        has_one :logistics
        has_one :web_info
        has_many :states
        has_many :web_info_sites
        has_many :descriptions
        has_many :promo_attribute_attachments
        has_one :image_relation
        has_many :cm_tags
      end

      belongs_to :concept_brand, -> { where(concept_id: 99) },
                 optional: true,
                 class_name: 'CatModels::ConceptBrand',
                 primary_key: :source_brand_id,
                 foreign_key: :brand_cd

      delegate :concept_vendor, to: :item_vendor, allow_nil: true

      belongs_to :eph_tree_node, -> { eph }, class_name: 'CatModels::TreeNode', primary_key: :source_code,
                                             foreign_key: :eph_prod_node_id, optional: true

      def description
        @description ||= External::XPDM::ConceptSkuDescription.new(descriptions)
      end

      # this allows concept-specific description instances to be created if needed
      def concept_description(_web_site_id)
        description
      end

      def chain_status
        PDM::SystemStatusMapper.value(chain_status_cd)
      end

      # the preloader accesses keys this way, and at least one of the items has a SPACE in the brand_cd
      def [](attr_name)
        if attr_name == :brand_cd
          read_attribute(:brand_cd).to_i # rubocop:disable Rails/ReadWriteAttribute
        else
          super
        end
      end
    end
  end
end
