class CreateInboundOKLProductRevisions < ActiveRecord::Migration[5.1]
  include InboundBatchReference

  def change
    create_table :inbound_okl_product_revisions do |t|
      references_inbound_batch(t)
      t.integer :product_id, limit: 8, null: false
      t.string :status, limit: 40
      t.string :name, limit: 255
      t.text :description
      t.string :pdp_url, limit: 512
    end
  end
end
