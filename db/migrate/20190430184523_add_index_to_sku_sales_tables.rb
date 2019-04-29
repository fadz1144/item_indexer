class AddIndexToSkuSalesTables < ActiveRecord::Migration[5.2]
  def change
    add_index :sku_sales_summary, :sku_id
    add_index :sku_sales_summary, :order_date
    add_index :sku_sales_summary, [:sku_id, :order_date], unique: true

    add_index :sku_sales, :sku_id
    add_index :sku_sales, :order_date
    add_index :sku_sales, [:sku_id, :order_date]

    add_index :sku_sales_incremental, :sku_id
    add_index :sku_sales_incremental, :order_date
    add_index :sku_sales_incremental, [:sku_id, :order_date]
  end
end
