class CreateInboundOKLSkuShippingRevisions < ActiveRecord::Migration[5.1]
  include InboundBatchReference

  def change
    create_table :inbound_okl_sku_shipping_revisions do |t|
      references_inbound_batch(t)
      t.integer :sku_id, limit: 8, null: false
      t.boolean :virtual_delivery
      t.boolean :returnable
      t.boolean :non_merchandise
      t.boolean :perishable
      t.boolean :white_glove
      t.boolean :entryway
      t.decimal :extra_shipping_charge, precision: 8, scale: 2
      t.boolean :vdc
      t.integer :lead_time
      t.integer :min_aad_offset_days
      t.integer :max_aad_offset_days
    end
  end
end
