class ConceptProduct < ApplicationRecord
  self.primary_key = :concept_product_id
  belongs_to :concept
  belongs_to :product
end
