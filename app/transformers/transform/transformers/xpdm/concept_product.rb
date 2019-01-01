module Transform
  module Transformers
    module XPDM
      class ConceptProduct < CatalogTransformer::Base
        source_name 'External::XPDM::ConceptProduct'
        include Transform::Transformers::XPDM::SharedConceptReferences

        attribute :description, source_name: :mstr_shrt_desc
        attribute :details, source_name: :mstr_web_desc
        attribute :source_product_id, association: :product, source_name: :pdm_object_id

        has_many :site_navigations, source_name: :site_navigations,
                                    match_keys: %i[root_tree_node branch_tree_node leaf_tree_node]

        exclude :product_id, :concept_category_id, :site_nav_tree_node_id

        module Decorations
          def concept
            Transform::ConceptCache.fetch(concept_id)
          end

          def name
            mstr_prod_desc.presence || vdr_web_prod_desc
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
