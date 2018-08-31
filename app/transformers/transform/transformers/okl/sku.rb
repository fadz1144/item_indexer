module Transform
  module Transformers
    module OKL
      class Sku < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuRevision'
        decorator_name 'Transform::Transformers::OKL::Decorators::SkuConceptSkuDecorator'

        has_many :product_memberships, match_keys: [:sku_id]
        attribute :sku_id, source_name: :sku_id
        attribute :gtin, source_name: :upc

        references :vendor, association: :concept_vendor
        references :brand, association: :concept_brand
        references :category, association: :concept_category
        references :merch_dept_tree_node
        references :merch_sub_dept_tree_node
        references :merch_class_tree_node

        exclude :eph_tree_node_id, :chain_status, :ecom_status, :rollup_type_cd, :rollup_type_name,
                allow_primary_key: true

        module Decorations
          def image_count
            images.size
          end
        end
      end
    end
  end
end
