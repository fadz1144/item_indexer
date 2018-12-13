module Transform
  module Transformers
    module OKL
      class Sku < CatalogTransformer::Base
        include Transform::Transformers::OKL::ProductAndSkuSharedRollups

        source_name 'Inbound::OKL::SkuRevision'
        decorator_name 'Transform::Transformers::OKL::Decorators::SkuConceptSkuDecorator'

        has_many :product_memberships, source_name: :itself, match_keys: [:product_id], partial: true
        attribute :sku_id, source_name: :sku_id
        attribute :gtin, source_name: :upc

        references :vendor, association: :concept_vendor
        references :brand, association: :concept_brand
        references :category, association: :concept_category

        # TODO: does the publish from OKL include the keys for these?
        # references :merch_dept_tree_node
        # references :merch_sub_dept_tree_node
        # references :merch_class_tree_node

        exclude :eph_tree_node_id, :ecom_status, :rollup_type_cd, :rollup_type_name,
                :tbs_blocked_reason_cd, :tbs_blocked_reason_name, :available_in_ca_dist_cd, :transferable_to_canada,
                :ca_fulfillment_cd, :ca_fulfillment_name, :vdc_sku, :jda_description, :pos_description,
                :units_sold_last_1_week, :units_sold_last_4_weeks, :units_sold_last_8_weeks, :units_sold_last_52_weeks,
                :merch_dept_tree_node_id, :merch_sub_dept_tree_node_id, :merch_class_tree_node_id, :restock_notifiable,
                :vdc_min_days_to_ship, :vdc_max_days_to_ship,
                allow_primary_key: true

        module Decorations
          def image_count
            images.size
          end

          def chain_status
            CatModels::Constants::SystemStatus::UNKNOWN
          end
        end

        private

        def other_concept_items
          @other_concept_items ||= CatModels::ConceptSku.where(sku_id: @source.sku_id).where.not(concept_id: 3)
        end
      end
    end
  end
end
