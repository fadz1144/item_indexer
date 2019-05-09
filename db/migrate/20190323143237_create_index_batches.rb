class CreateIndexBatches < ActiveRecord::Migration[5.2]
  def change
    create_table :index_batches, id: false, comment: 'Log of indexings performed' do |t|
      t.primary_key :index_batch_id
      t.string :status, limit:30, null: false, default: 'in progress', comment: 'in progress / complete / error'
      t.integer :error_count, comment: 'rollup of number of errors in batch'
      t.string :status_reason, limit:255, comment: 'Additional status details'
      t.datetime :start_datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :stop_datetime, null: true
    end
  end
end
