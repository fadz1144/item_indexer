class CreateInboundOKLSkuAttributeRevisions < ActiveRecord::Migration[5.1]
  include InboundBatchReference

  def change
    create_table :inbound_okl_sku_attribute_revisions do |t|
      references_inbound_batch(t)
      t.integer :sku_id, limit: 8, null: false
      t.integer :sku_attribute_id
      t.string :code
      t.string :value
    end
  end
end
