module Transform
  module Transformers
    module XPDM
      class ConceptCollection < CatalogTransformer::Base
        source_name 'External::XPDM::ConceptCollection'
        include Transform::Transformers::XPDM::SharedConceptReferences

        attribute :name, source_name: :mstr_prod_desc
        attribute :description, source_name: :mstr_shrt_desc
        attribute :details, source_name: :mstr_web_desc
        attribute :source_collection_id, association: :collection, source_name: :pdm_object_id

        exclude :collection_id

        module Decorations
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
