module Transform
  module Transformers
    module OKL
      class ConceptCategory < CatalogTransformer::Base
        source_name 'Inbound::OKL::CategoryRevision'
        match_keys :source_category_id

        attribute :parent_id, source_name: :parent_category_id

        belongs_to :category

        def self.target_relation
          super.where(concept_id: CONCEPT_ID)
        end

        module Decorations
          def concept_id
            CONCEPT_ID
          end

          def parent_category_id
            parent_concept_category&.concept_category_id
          end

          def active
            status == 'ACTIVE'
          end

          def source_created_at
            super || '1976-07-06'.to_datetime
          end
        end
      end
    end
  end
end
