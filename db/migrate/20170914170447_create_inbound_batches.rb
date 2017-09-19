class CreateInboundBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :inbound_batches, id: false, comment: 'Log of batches received' do |t|
      t.primary_key :inbound_batch_id
      t.string :source, limit: 10, null: false, comment: 'OKL / PDM / CPWM'
      t.string :data_type, limit: 40, null: false, comment: 'sku / product'
      t.string :status, limit: 30, null: false, default: 'in progress', comment: 'in progress / complete / error'
      t.string :status_reason, limit: 255, comment: 'Additional status details'
      t.string :file_name, limit: 255, comment: 'Optional: backup of message or SQL script'
      t.datetime :start_datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :stop_datetime, null: true
    end
  end
end

module InboundBatchReference
  def references_inbound_batch(table)
    table.references :inbound_batch, type: :integer, limit: 8, null: false,
                     foreign_key: { primary_key: :inbound_batch_id, name: :inb_okl_sku_rvn__fk_inbound_batch_id }

  end
end
