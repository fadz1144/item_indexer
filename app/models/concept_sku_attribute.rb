class ConceptSkuAttribute < ApplicationRecord
  self.primary_key = :concept_sku_attribute_id
  belongs_to :concept_sku
end
