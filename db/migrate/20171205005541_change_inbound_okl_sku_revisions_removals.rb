class ChangeInboundOKLSkuRevisionsRemovals < ActiveRecord::Migration[5.1]
  def up
    change_table :inbound_okl_sku_revisions do |t|
      t.remove :jda_id
      t.remove :brand_id
      t.remove :name
      t.remove :line_of_business
      t.remove :product_id
      t.remove :color
      t.remove :color_family
      t.remove :size
      t.remove :material
      t.remove :shipping_method
    end

    change_table :inbound_okl_sku_dimensions_revisions do |t|
      t.remove :cost
    end
  end

  def down
    change_table :inbound_okl_sku_revisions do |t|
      t.integer :jda_id, limit: 8, null: false
      t.integer :brand_id, limit: 8
      t.string :name, limit: 255
      t.string :line_of_business, limit: 255
      t.integer :product_id, limit: 8
      t.string :color, limit: 255
      t.string :color_family, limit: 255
      t.string :size, limit: 255
      t.string :material, limit: 255
      t.string :shipping_method, limit: 40
    end

    change_table :inbound_okl_sku_dimensions_revisions do |t|
      t.decimal :cost, precision: 8, scale: 2
    end
  end
end
