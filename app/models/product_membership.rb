class ProductMembership < ApplicationRecord
  self.primary_key = :product_membership_id
  belongs_to :product
  belongs_to :sku
end
