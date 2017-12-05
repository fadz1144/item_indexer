class AddShapesToInboundOKLSkuDimensionsRevisions < ActiveRecord::Migration[5.1]
  def change
    change_table :inbound_okl_sku_dimensions_revisions do |t|
      t.string :item_dimension_shape
      t.string :shipping_dimension_shape
      t.integer :source_created_by
      t.datetime :source_created_at
      t.integer :source_updated_by
      t.datetime :source_updated_at
    end
  end
end
