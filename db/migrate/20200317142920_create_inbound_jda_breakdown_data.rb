class CreateInboundJdaBreakdownData < ActiveRecord::Migration[5.2]
  def change
    create_table :inbound_jda_breakdown_data do |t|
      references_inbound_batch(t)

      t.integer :ISTORE, null: false, comment: 'Store'
      t.integer :INUMBER, null: false, comment: 'SKU Number'
      t.integer :IBHAND, null: false, comment: 'Inventory in hhand'
      t.integer :IBPOOQ, null: false, comment: 'Inventory'

    end
  end
end