module Transform
  module Transformers
    module XPDM
      class ConceptCollection < CatalogTransformer::Base
        source_name 'External::XPDM::ConceptCollection'
        include Transform::Transformers::XPDM::SharedConceptReferences
        include Transform::Transformers::XPDM::SharedConceptAttributes

        attribute :name, source_name: :mstr_prod_desc
        attribute :description, source_name: :mstr_shrt_desc
        attribute :details, source_name: :mstr_web_desc
        attribute :source_collection_id, association: :collection, source_name: :pdm_object_id
        attribute :price_string, source_name: :web_prc_str_desc

        has_many :site_navigations, source_name: :site_navigations,
                                    match_keys: %i[root_tree_node branch_tree_node leaf_tree_node]

        exclude :collection_id, :site_nav_tree_node_id

        module Decorations
          include Transform::Transformers::XPDM::SharedConceptMethods

          def concept
            Transform::ConceptCache.fetch(concept_id)
          end

          def active
            live_on_site?
          end

          def status
            active ? 'Active' : 'Inactive'
          end
        end
      end
    end
  end
end
