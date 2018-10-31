module Transform
  module Transformers
    module XPDM
      class ConceptProduct < CatalogTransformer::Base
        source_name 'External::XPDM::ConceptProduct'
        include Transform::Transformers::XPDM::SharedConceptReferences

        attribute :description, source_name: :mstr_shrt_desc
        attribute :details, source_name: :mstr_web_desc
        attribute :source_product_id, association: :product, source_name: :pdm_object_id

        exclude :product_id, :concept_category_id

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
