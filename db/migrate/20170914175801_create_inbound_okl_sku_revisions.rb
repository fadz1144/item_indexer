class CreateInboundOKLSkuRevisions < ActiveRecord::Migration[5.1]
  include InboundBatchReference

  def change
    create_table :inbound_okl_sku_revisions do |t|
      references_inbound_batch(t)
      t.integer :sku_id, limit: 8, null: false
      t.integer :jda_id, limit: 8, null: false
      t.integer :upc, limit: 8
      t.integer :brand_id, limit: 8
      t.string :name, limit: 255
      t.string :line_of_business, limit: 255
      t.integer :product_id, limit: 8
      t.decimal :cost, precision: 8, scale: 2
      t.decimal :price, precision: 8, scale: 2
      t.decimal :pre_markdown_price, precision: 8, scale: 2
      t.string :color, limit: 255
      t.string :color_family, limit: 255
      t.string :size, limit: 255
      t.string :material, limit: 255
      t.string :shipping_method, limit: 40
    end
  end
end
