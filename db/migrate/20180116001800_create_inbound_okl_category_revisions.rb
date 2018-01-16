class CreateInboundOKLCategoryRevisions < ActiveRecord::Migration[5.1]
  def change
    create_table :inbound_okl_category_revisions do |t|
      t.references :inbound_batch, type: :integer, limit: 8, null: false,
                   foreign_key: { primary_key: :inbound_batch_id, name: :inb_okl_cat_rvn__fk_inbound_batch_id }
      t.integer :source_category_id, limit: 8, null: false
      t.string :name
      t.text :description
      t.string :status
      t.integer :parent_id, limit: 8
      t.integer :source_created_by
      t.datetime :source_created_at
      t.integer :source_updated_by
      t.datetime :source_updated_at
    end
  end
end
