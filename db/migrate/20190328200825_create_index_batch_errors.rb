class CreateIndexBatchErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :index_batch_errors, id: false, comment: 'Batch indexing errors' do |t|
      t.primary_key :index_batch_error_id
      t.references :index_batch, type: :integer, limit: 8, null: false,
                   foreign_key: { primary_key: :index_batch_id, name: :index_batch_errors___fk_index_batch_id }
      t.references :indexed_item, polymorphic: true, index: { name: 'index_batch_errors__idx_indexed_item' }
      t.string :message
    end
  end
end
