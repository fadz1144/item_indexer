class ConceptSku < ApplicationRecord
  self.primary_key = :concept_sku_id
  belongs_to :concept
  belongs_to :sku
  has_many :concept_sku_attributes
end
