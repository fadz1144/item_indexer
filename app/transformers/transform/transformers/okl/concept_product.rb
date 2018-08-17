module Transform
  module Transformers
    module OKL
      class ConceptProduct < CatalogTransformer::Base
        source_name 'Inbound::OKL::ProductRevision'
        match_keys :source_product_id
        decorator_name 'Transform::Transformers::OKL::Decorators::ProductConceptProductDecorator'

        exclude :site_nav_tree_node_id

        belongs_to :product

        def self.target_relation
          super.where(concept_id: CONCEPT_ID)
        end

        module Decorations
          def concept_id
            CONCEPT_ID
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
