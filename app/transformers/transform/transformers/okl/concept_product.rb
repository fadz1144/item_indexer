module Transform
  module Transformers
    module OKL
      class ConceptProduct < CatalogTransformer::Base
        source_name 'Inbound::OKL::ProductRevision'
        match_keys :source_product_id

        belongs_to :product

        attribute :concept_vendor_id, source_name: :vendor_id # TODO: remove when concept_vendors is fixed

        def self.target_relation
          super.where(concept_id: CONCEPT_ID)
        end

        module Decorations
          def concept_id
            CONCEPT_ID
          end

          def active
            status == 'ACTIVE'
          end

          # TODO: do we want to truncate long descriptions, or remove the restriction in the database?
          def description
            super[0...1000] if super.present?
          end

          def source_created_at
            super || '1976-07-06'.to_datetime
          end
        end
      end
    end
  end
end
