class Brand < ApplicationRecord
  self.primary_key = :brand_id
  has_many :concept_brands
end
