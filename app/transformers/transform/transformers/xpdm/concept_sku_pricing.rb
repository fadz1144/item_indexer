module Transform
  module Transformers
    module XPDM
      class ConceptSkuPricing < CatalogTransformer::Base
        source_name 'External::XPDM::Sku'
        attribute :sku_id, source_name: :pdm_object_id
        attribute :source_sku_id, source_name: :pdm_object_id
        references :concept

        # retail_price, margin_amount, and margin_percent are populated by JDA concept sku pricing transformation
        exclude :concept_sku_id, :retail_price, :pre_markdown_price, :map_price, :contribution_margin_amount,
                :contribution_margin_percent, :cm_amount_sum_l4w, :cm_rate_l4w, :cm_sales_units_sum_l4w,
                :cm_retail_sales_sum_l4w, :cm_coupon_sum_l4w, :cm_sales_cost_sum_l4w, :cm_freight_in_sum_l4w,
                :cm_freight_out_sum_l4w, :cm_shipping_paid_by_customer_sum_l4w, :cm_shrink_sum_l4w,
                :cm_net_damages_sum_l4w, :cm_marked_out_of_stock_sum_l4w, :cm_markdown_reimbursement_sum_l4w,
                :cm_vendor_funded_allowances_sum_l4w, :cm_net_sales_retail_sum_l4w, :cm_cost_sum_l4w,
                :cm_amount_l4w, :cm_retail_sales_l4w, :cm_coupon_l4w, :cm_sales_cost_l4w, :cm_freight_in_l4w,
                :cm_freight_out_l4w, :cm_shipping_paid_by_customer_l4w, :cm_shrink_l4w, :cm_net_damages_l4w,
                :cm_marked_out_of_stock_l4w, :cm_markdown_reimbursement_l4w, :cm_vendor_funded_allowances_l4w,
                :cm_net_sales_retail_l4w, :cm_cost_l4w, :cm_l4w_updated_at, :cm_l52w_updated_at,
                :margin_amount, :margin_percent, :total_sales_units_l1w, :total_sales_units_l8w, :total_sales_units_l52w
      end
    end
  end
end
