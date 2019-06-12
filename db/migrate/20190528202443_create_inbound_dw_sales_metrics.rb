require_relative '20170914170447_create_inbound_batches'
class CreateInboundDWSalesMetrics < ActiveRecord::Migration[5.2]
  include InboundBatchReference
  def change
    create_table :inbound_dw_sales_metrics_feed, primary_key: :id do |t|
      references_inbound_batch(t)
      t.integer :sku_id, null: false, comment: 'SKU'
      t.string :site_id, limit: 20, null: false, comment: 'identifies the concept'
      t.integer :total_sales_units_l1w, comment: 'maps to total_sales_units_l1w'
      t.integer :total_sales_units_l8w, comment: 'maps to total_sales_units_l8w'
      t.integer :total_sales_units_l52w, comment: 'maps to total_sales_units_l52w'
      t.timestamp :file_mod_time
    end
  end
end