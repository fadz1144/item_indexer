class CreateInboundOKLSkuInventoryRevisions < ActiveRecord::Migration[5.1]
  def change
    create_table :inbound_okl_sku_inventory_revisions do |t|
      t.references :inbound_batch, type: :integer, limit: 8, null: false,
        foreign_key: { primary_key: :inbound_batch_id, name: :inb_okl_sku_rvn__fk_inbound_batch_id }
      t.integer :sku_id, limit: 8, null: false

      t.integer :total_avail_qty
      t.integer :warehouse_avail_qty
      t.integer :stores_avail_qty
      t.integer :vdc_avail_qty
      t.integer :on_order_qty
    end
  end
end
