class CreateSkuSales < ActiveRecord::Migration[5.2]
  def change
    create_table :sku_sales_incremental, primary_key: :sku_sales_incremental_id do |t|
      t.integer :sku_id, limit: 8, null: false
      t.timestamp :order_date, null: false
      t.string :origin_cd, limit: 15, null: false
      t.string :reg_order_flag, limit: 1, default: 'N', null: false
      t.integer :order_count, default: 0
      t.integer  :order_qty, default: 0
      t.decimal :unit_cost, precision: 12, scale: 2, default: 0
      t.decimal :sales_amount, precision: 12, scale: 2
      t.timestamp :row_xng_date
      t.decimal :discount_amount, precision: 5, scale: 2

      t.timestamps
    end

    create_table :sku_sales, primary_key: :sku_sales_id do |t|
      t.integer :sku_id, limit: 8, null: false
      t.timestamp :order_date, null: false
      t.string :origin_cd, limit: 15, null: false
      t.string :reg_order_flag, limit: 1, default: 'N', null: false
      t.integer :order_count, default: 0
      t.integer  :order_qty, default: 0
      t.decimal :unit_cost, precision: 12, scale: 2, default: 0
      t.decimal :sales_amount, precision: 12, scale: 2
      t.timestamp :row_xng_date
      t.decimal :discount_amount, precision: 5, scale: 2

      t.timestamps
    end

    create_table :sku_sales_summary, primary_key: :sku_sales_summary_id do |t|
      t.integer :sku_id, limit: 8, null: false
      t.timestamp :order_date, null: false
      t.integer :order_count, default: 0
      t.integer  :order_qty, default: 0
      t.decimal :sales_amount, precision: 12, scale: 2

      t.timestamps
    end
  end
end
