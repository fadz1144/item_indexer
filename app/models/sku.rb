class Sku < ApplicationRecord
  self.primary_key = :sku_id
  has_many :concept_skus
end
