class AddTransformBatchToInboundBatch < ActiveRecord::Migration[5.1]
  def change
    change_table :inbound_batches do |t|
      t.references :transform_batch, type: :integer, limit: 8,
                   foreign_key: { primary_key: :transform_batch_id, name: :transform_batches__fk_transform_batch_id }
    end
  end
end
