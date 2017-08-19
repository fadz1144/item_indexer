class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products, id: false, comment: 'Product definition' do |t|
      t.primary_key :product_id, comment: 'Globally unique id for product'
      t.integer :membership_hash, limit: 8, comment: 'Hash of member sku_ids'

      t.timestamps
    end
  end
end
