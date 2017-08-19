class Concept < ApplicationRecord
  self.primary_key = :concept_id
  has_many :concept_brands
  has_many :concept_skus
  has_many :concept_products
end
