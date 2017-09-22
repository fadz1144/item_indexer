class CreateInboundOKLSkuImageRevisions < ActiveRecord::Migration[5.1]
  include InboundBatchReference

  def change
    create_table :inbound_okl_sku_image_revisions do |t|
      references_inbound_batch(t)
      t.integer :sku_id, limit: 8, null: false
      t.integer :image_id, limit: 8, null: false
      t.string :hosting_service
      t.string :resource_folder
      t.string :resource_path
      t.string :resource_name
      t.integer :sort_order
      t.boolean :primary
      t.boolean :active
    end
  end
end
