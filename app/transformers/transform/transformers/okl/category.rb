module Transform
  module Transformers
    module OKL
      class Category < CatalogTransformer::Base
        source_name 'Inbound::OKL::CategoryRevision'

        attribute :parent_id, source_name: :parent_category_id

        module Decorations
          def parent_category_id
            parent_concept_category&.category_id
          end

          def level
            if source_category_id % 10_000 == 0
              1
            elsif source_category_id % 100 == 0
              2
            else
              3
            end
          end
        end
      end
    end
  end
end
