class CreateInboundOKLSkuStateRevisions < ActiveRecord::Migration[5.1]
  include InboundBatchReference

  def change
    create_table :inbound_okl_sku_state_revisions do |t|
      references_inbound_batch(t)
      t.integer :sku_id, limit: 8, null: false
      t.boolean :content_ready
      t.boolean :copy_ready
      t.boolean :vetted
      t.boolean :exists_in_storefront
      t.string :exclusivity_tier
      t.integer :inactive_reason_id, 'obsolete reason id'
      t.string :status_reason, 'obsolete reason name'
    end
  end
end
