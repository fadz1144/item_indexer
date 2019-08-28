module Transform
  module Transformers
    module XPDM
      class Collection < CatalogTransformer::Base
        source_name 'External::XPDM::Collection'
        match_keys :source_collection_id, source_key: :pdm_object_id
        include Transform::Transformers::XPDM::WebFlagsSummaryRollup
        include Transform::Transformers::XPDM::WebStatusRollup
        include Transform::Transformers::XPDM::SharedReferences

        has_many :concept_collections, source_name: :concept_collections, match_keys: [:concept]
        has_many :collection_memberships, source_name: :collection_memberships, match_keys: [:product_id]
        has_many :tags, source_name: :cm_tags, match_keys: [:tag_value]
        has_many :promo_attributes, source_name: :promo_attribute_attachments, match_keys: [:promo_cd]

        attribute :web_copy_complete_status, source_name: :web_copy_cmplt_ind, association: :web_info

        # manually building this because the TransformerNonActiveRecordModel's need a little help
        def self.source_includes # rubocop:disable Metrics/MethodLength
          [{ item_vendor: { concept_vendor: :vendor } }, { concept_brand: :brand },
           { eph_tree_node: :tree },
           { merch_dept_tree_node: :tree }, { merch_sub_dept_tree_node: :tree }, { merch_class_tree_node: :tree },
           :states, :descriptions,
           { bbby_site_navigations: { root_tree_node: :tree, branch_tree_node: :tree, leaf_tree_node: :tree } },
           { ca_site_navigations: { root_tree_node: :tree, branch_tree_node: :tree, leaf_tree_node: :tree } },
           { baby_site_navigations: { root_tree_node: :tree, branch_tree_node: :tree, leaf_tree_node: :tree } },
           :web_info_sites,
           { collection_memberships: { concept_product: :product } },
           { promo_attribute_attachments: :all_concept_flags },
           :cm_tags]
        end

        def assign_web_flags_summary(target)
          target.web_flags_summary = web_flags_summary_rollup(target.concept_collections)
        end

        def assign_web_status(target)
          target.web_status = web_status_rollup(target.concept_collections)
        end

        def self.load_indexed_targets(source_records)
          source_ids = source_records.map(&:pdm_object_id)
          # get the collection Id to source collection Id mapping from concept collections
          ids = CatModels::ConceptCollection.where(source_collection_id: source_ids)
                                            .distinct.pluck(:collection_id, :source_collection_id).to_h
          # index the collections by the source collection Id
          target_relation.where(collection_id: ids.keys).index_by { |p| ids[p.collection_id] }
        end
      end
    end
  end
end
