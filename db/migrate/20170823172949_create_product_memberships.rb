class CreateProductMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :product_memberships, id: false, comment: 'Sku membership for each product' do |t|
      t.primary_key :product_membership_id
      t.integer :product_id, limit: 8, index: { name: 'product_memberships__idx_product_id' }
      t.integer :sku_id, limit: 8, index: { name: 'product_to_memberships__idx_sku_id' }

      t.timestamps
    end

    add_index :product_memberships, [:product_id, :sku_id], unique: true, name: :product_memberships__idx_product_id_sku_id
  end
end
