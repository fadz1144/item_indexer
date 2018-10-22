module Transform
  module Transformers
    module OKL
      class Sku < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuRevision'
        decorator_name 'Transform::Transformers::OKL::Decorators::SkuConceptSkuDecorator'

        has_many :product_memberships, match_keys: [:sku_id], partial: true
        attribute :sku_id, source_name: :sku_id
        attribute :gtin, source_name: :upc

        references :vendor, association: :concept_vendor
        references :brand, association: :concept_brand
        references :category, association: :concept_category
        references :merch_dept_tree_node
        references :merch_sub_dept_tree_node
        references :merch_class_tree_node

        exclude :eph_tree_node_id, :chain_status, :ecom_status, :rollup_type_cd, :rollup_type_name,
                :tbs_blocked_reason_cd, :tbs_blocked_reason_name, :available_in_ca_dist_cd, :transferable_to_canada,
                :ca_fulfillment_cd, :ca_fulfillment_name, :vdc_sku, :jda_description, :pos_description,
                :units_sold_last_1_week, :units_sold_last_4_weeks, :units_sold_last_8_weeks, :units_sold_last_52_weeks,
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
