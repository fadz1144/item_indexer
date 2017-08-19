class Product < ApplicationRecord
  self.primary_key = :product_id
  has_many :concept_products
  has_many :product_memberships
  has_many :skus, through: :product_memberships
end
