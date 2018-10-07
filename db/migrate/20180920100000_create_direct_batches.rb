class CreateDirectBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :direct_batches, id: false, comment: 'Log of batches loaded directly' do |t|
      t.primary_key :direct_batch_id
      t.references :transform_batch, type: :integer, limit: 8,
                   foreign_key: { primary_key: :transform_batch_id, name: :direct_batches__fk_transform_batch_id }
      t.string :class_name, null: false
      t.string :criteria_type, null: false
      t.string :criteria
      t.integer :count, limit: 8
    end
  end
end
