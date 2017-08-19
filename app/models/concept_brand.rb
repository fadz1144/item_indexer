class ConceptBrand < ApplicationRecord
  self.primary_key = :concept_brand_id
  belongs_to :concept
  belongs_to :brand
end
