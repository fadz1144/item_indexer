module Inbound
  module OKL
    class SkuRevision < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
      { foreign_key: :inbound_okl_sku_revision_id, inverse_of: :sku }.tap do |sku_options|
        has_one :state, sku_options.merge(class_name: 'Inbound::OKL::SkuStateRevision')
        has_one :shipping, sku_options.merge(class_name: 'Inbound::OKL::SkuShippingRevision')
        has_one :dimensions, sku_options.merge(class_name: 'Inbound::OKL::SkuDimensionsRevision')
        has_one :inventory, sku_options.merge(class_name: 'Inbound::OKL::SkuInventoryRevisions')
        has_many :images, sku_options.merge(class_name: 'Inbound::OKL::SkuImageRevision')
        has_many :sku_attributes, sku_options.merge(class_name: 'Inbound::OKL::SkuAttributeRevision')
      end

      # foreign keys
      belongs_to :concept_product, -> { where(concept_id: 3) },
                 optional: true,
                 class_name: 'CatModels::ConceptProduct',
                 primary_key: :source_product_id,
                 foreign_key: :source_product_id
      include Inbound::CommonConceptForeignKeys

      belongs_to :polished_sku,
                 optional: true,
                 class_name: 'CatModels::Sku',
                 primary_key: :sku_id,
                 foreign_key: :sku_id

      validates :sku_id, :source_sku_id, presence: true
    end
  end
end
