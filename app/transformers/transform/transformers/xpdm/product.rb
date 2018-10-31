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

        exclude :category_id, :membership_hash

        # manually building this because the TransformerNonActiveRecordModel's need a little help
        def self.source_includes
          [{ item_vendor: { concept_vendor: :vendor } }, { concept_brand: :brand },
           { eph_tree_node: :tree },
           { merch_dept_tree_node: :tree }, { merch_sub_dept_tree_node: :tree }, { merch_class_tree_node: :tree },
           :states, :descriptions,
           { bbby_site_navigation: { site_nav_tree_node: :tree } },
           { ca_site_navigation: { site_nav_tree_node: :tree } },
           { baby_site_navigation: { site_nav_tree_node: :tree } }]
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
          CatModels::Product.includes(:concept_products).where(product_id: ids.keys).index_by { |p| ids[p.product_id] }
        end
      end
    end
  end
end
