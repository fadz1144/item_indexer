module Transform
  module Transformers
    module XPDM
      class Product < CatalogTransformer::Base
        source_name 'External::XPDM::Product'
        match_keys :source_product_id, source_key: :pdm_object_id
        include Transform::Transformers::XPDM::WebFlagsSummaryRollup
        include Transform::Transformers::XPDM::WebStatusRollup
        include Transform::Transformers::XPDM::SharedReferences

        has_many :concept_products, source_name: :concept_products, match_keys: [:concept]
        has_many :tags, source_name: :cm_tags, match_keys: [:tag_value]
        has_many :promo_attributes, source_name: :promo_attribute_attachments, match_keys: [:promo_cd]

        attribute :restock_notifiable, association: :web_info, source_name: :email_cust_for_oos_ind
        attribute :vdc_min_days_to_ship, association: :logistics, source_name: :vdc_min_day_to_shp
        attribute :vdc_max_days_to_ship, association: :logistics, source_name: :vdc_max_day_to_shp
        attribute :web_copy_complete_status, source_name: :web_copy_cmplt_ind, association: :web_info
        attribute :map_price, source_name: :map_prc_amt, association: :cost
        attribute :rollup_type_name, source_name: :rlup_type_name

        exclude :category_id, :membership_hash

        # manually building this because the TransformerNonActiveRecordModel's need a little help
        def self.source_includes
          [{ item_vendor: { concept_vendor: :vendor } }, { concept_brand: :brand },
           { eph_tree_node: :tree },
           { merch_dept_tree_node: :tree }, { merch_sub_dept_tree_node: :tree }, { merch_class_tree_node: :tree },
           :states, :descriptions,
           { bbby_site_navigations: { root_tree_node: :tree, branch_tree_node: :tree, leaf_tree_node: :tree } },
           { ca_site_navigations: { root_tree_node: :tree, branch_tree_node: :tree, leaf_tree_node: :tree } },
           { baby_site_navigations: { root_tree_node: :tree, branch_tree_node: :tree, leaf_tree_node: :tree } },
           { promo_attribute_attachments: :all_concept_flags },
           :cm_tags, :web_info, :web_info_sites, :logistics]
        end

        def assign_web_flags_summary(target)
          target.web_flags_summary = web_flags_summary_rollup(target.concept_products)
        end

        def assign_web_status(target)
          target.web_status = web_status_rollup(target.concept_products)
        end

        def self.load_indexed_targets(source_records)
          source_ids = source_records.map(&:pdm_object_id)
          # get the product Id to source product Id mapping from concept skus
          ids = CatModels::ConceptProduct.where(source_product_id: source_ids)
                                         .distinct.pluck(:product_id, :source_product_id).to_h
          # index the products by the source product Id
          target_relation.where(product_id: ids.keys).index_by { |p| ids[p.product_id] }
        end
      end
    end
  end
end
