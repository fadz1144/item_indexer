module Transform
  module Transformers
    module OKL
      class ConceptSkuPricing < CatalogTransformer::Base
        include Transform::Transformers::MarginCalculator
        source_name 'Inbound::OKL::SkuRevision'
        attribute :retail_price, source_name: :price
        exclude :concept_sku_id, :contribution_margin_amount, :contribution_margin_percent, :cm_amount_sum_l4w,
                :cm_rate_l4w, :cm_sales_units_sum_l4w, :cm_retail_sales_sum_l4w, :cm_coupon_sum_l4w,
                :cm_sales_cost_sum_l4w, :cm_freight_in_sum_l4w, :cm_freight_out_sum_l4w,
                :cm_shipping_paid_by_customer_sum_l4w, :cm_shrink_sum_l4w, :cm_net_damages_sum_l4w,
                :cm_marked_out_of_stock_sum_l4w, :cm_markdown_reimbursement_sum_l4w,
                :cm_vendor_funded_allowances_sum_l4w, :cm_net_sales_retail_sum_l4w, :cm_cost_sum_l4w,
                :cm_amount_l4w, :cm_retail_sales_l4w, :cm_coupon_l4w, :cm_sales_cost_l4w, :cm_freight_in_l4w,
                :cm_freight_out_l4w, :cm_shipping_paid_by_customer_l4w, :cm_shrink_l4w, :cm_net_damages_l4w,
                :cm_marked_out_of_stock_l4w, :cm_markdown_reimbursement_l4w, :cm_vendor_funded_allowances_l4w,
                :cm_net_sales_retail_l4w, :cm_cost_l4w,
                :margin_amount, :margin_percent

        after_transform :calculate_margin

        module Decorations
          def concept_id
            CONCEPT_ID
          end
        end
      end
    end
  end
end
