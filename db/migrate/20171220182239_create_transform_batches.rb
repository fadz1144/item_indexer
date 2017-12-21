class CreateTransformBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :transform_batches, id: false, comment: 'Log of batches tranformed' do |t|
      t.primary_key :transform_batch_id
      t.string :status, limit: 30, null: false, default: 'in progress', comment: 'in progress / complete / error'
      t.string :status_reason, limit: 255, comment: 'Additional status details'
      t.datetime :start_datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :stop_datetime, null: true
    end
  end
end
