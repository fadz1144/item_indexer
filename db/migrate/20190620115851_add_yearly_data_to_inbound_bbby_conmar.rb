class AddYearlyDataToInboundBBBYConmar < ActiveRecord::Migration[5.2]
  def change
    add_column :inbound_dw_contribution_margin_feed, :cm_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_amount_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :cm_rate_l52w, :decimal, precision: 9, scale: 2,
               comment: 'maps to cm_rate_l52w'
    add_column :inbound_dw_contribution_margin_feed, :sls_unit_l52w, :integer, comment: 'maps to cm_sales_units_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :sls_ret_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_retail_sales_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :coupon_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_coupon_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :sls_cost_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_sales_cost_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :freight_in_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_freight_in_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :freight_out_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_freight_out_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :ship_fee_coll_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_shipping_paid_by_customer_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :shrink_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_shrink_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :rtv_da_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_net_damages_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :rtv_mos_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_marked_out_of_stock_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :md_reimb_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_markdown_reimbursement_sum_l52w'
    add_column :inbound_dw_contribution_margin_feed, :vend_supp_l52w, :decimal, precision: 10, scale: 2,
               comment: 'maps to cm_vendor_funded_allowances_sum_l52w'
  end
end
