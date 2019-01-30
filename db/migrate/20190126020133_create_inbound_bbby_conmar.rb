require_relative '20170914170447_create_inbound_batches'
class CreateInboundBBBYConmar < ActiveRecord::Migration[5.2]
  include InboundBatchReference
  def change
    create_table :inbound_dw_contribution_margin_feed, primary_key: :id do |t|
      references_inbound_batch(t)
      t.integer :sku_id, null: false, comment: 'SKU'
      t.string :site_id, limit: 20, null: false, comment: 'identifies the concept'
      t.decimal :cm_l4w, precision: 8, scale: 2, comment: 'maps to cm_amount_sum_l4w'
      t.decimal :cm_rate_l4w, precision: 9, scale: 4, comment: 'maps to cm_rate_l4w'
      t.integer :sls_unit_l4w, comment: 'maps to cm_sales_units_sum_l4w'
      t.decimal :sls_ret_l4w, precision: 10, scale: 2, comment: 'maps to cm_retail_sales_sum_l4w'
      t.decimal :coupon_l4w, precision: 10, scale: 2, comment: 'maps to cm_coupon_sum_l4w'
      t.decimal :sls_cost_l4w, precision: 10, scale: 2, comment: 'maps to cm_sales_cost_sum_l4w'
      t.decimal :freight_in_l4w, precision: 8, scale: 2, comment: 'maps to cm_freight_in_sum_l4w'
      t.decimal :freight_out_l4w, precision: 8, scale: 2, comment: 'maps to cm_freight_out_sum_l4w'
      t.decimal :ship_fee_coll_l4w, precision: 8, scale: 2, comment: 'maps to cm_shipping_paid_by_customer_sum_l4w'
      t.decimal :shrink_l4w, precision: 8, scale: 2, comment: 'maps to cm_shrink_sum_l4w'
      t.decimal :rtv_da_l4w, precision: 8, scale: 2, comment: 'maps to cm_net_damages_sum_l4w'
      t.decimal :rtv_mos_l4w, precision: 8, scale: 2, comment: 'maps to cm_marked_out_of_stock_sum_l4w'
      t.decimal :md_reimb_l4w, precision: 8, scale: 2, comment: 'maps to cm_markdown_reimbursement_sum_l4w'
      t.decimal :vend_supp_l4w, precision: 8, scale: 2, comment: 'maps to cm_vendor_funded_allowances_sum_l4w'
    end
  end
end
