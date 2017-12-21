class CreateTransformBatchErrors < ActiveRecord::Migration[5.1]
  def change
    create_table :transform_batch_errors, id: false, comment: 'Batch transformation errors' do |t|
      t.primary_key :transform_batch_error_id
      t.references :transform_batch, type: :integer, limit: 8, null: false,
                   foreign_key: { primary_key: :transform_batch_id, name: :tfm_batch_errors___fk_transform_batch_id }
      t.references :source_item, polymorphic: true, index: { name: 'tfm_batch_errors__idx_source_item' }
      t.string :message
    end
  end
end
