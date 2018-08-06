module Transform
  module Transformers
    module OKL
      class ConceptBrand < CatalogTransformer::Base
        source_name 'Inbound::OKL::BrandRevision'
        match_keys :source_brand_id

        belongs_to :brand, match_keys: :name

        def self.target_relation
          super.where(concept_id: CONCEPT_ID)
        end

        module Decorations
          def concept_id
            CONCEPT_ID
          end

          def name
            super || description
          end

          def status
            active? ? 'ACTIVE' : 'INACTIVE'
          end

          def source_created_at
            super || '1976-07-06'.to_datetime
          end
        end
      end
    end
  end
end
