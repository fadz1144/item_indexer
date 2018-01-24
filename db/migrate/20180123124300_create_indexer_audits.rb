class CreateIndexerAudits < ActiveRecord::Migration[5.1]
  def change
    create_table :indexer_audits, id: false, comment: 'Log of indexer actions' do |t|
      t.primary_key :indexer_audit_id
      t.string :index_type, limit: 30, null: false, comment: 'product / sku'
      t.string :status, limit: 30, null: false, default: 'in progress', comment: 'in progress / complete / error'
      t.string :status_reason, limit: 255, comment: 'Additional status details'
      t.datetime :important_datetime, null: false,
                 comment: 'datetime of the reference table (based upon index type) for processing'
      t.integer :counter, null: true, comment: 'For reference and benchmarking, this is the size of this indexer run'
      t.datetime :start_datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :stop_datetime, null: true
    end
  end
end
