class AddColumnsToInboundOKLProductRevsions < ActiveRecord::Migration[5.1]
  def change
    change_table :inbound_okl_product_revisions do |t|
      t.rename :product_id, :source_product_id
      t.integer :brand_id, limit: 8
      t.integer :vendor_id, limit: 8
      t.integer :category_id, limit: 8
      t.integer :source_created_by
      t.datetime :source_created_at
      t.integer :source_updated_by
      t.datetime :source_updated_at
    end
  end
end
