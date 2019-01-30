module Transform
  module Transformers
    module XPDM
      class ConceptSkuPricing < CatalogTransformer::Base
        source_name 'External::XPDM::Sku'
        attribute :sku_id, source_name: :pdm_object_id
        attribute :source_sku_id, source_name: :pdm_object_id
        attribute :retail_price, source_name: :price
        references :concept

        exclude :concept_sku_id, :pre_markdown_price, :map_price, :contribution_margin_amount,
                :contribution_margin_percent, :cm_amount_sum_l4w, :cm_rate_l4w, :cm_sales_units_sum_l4w,
                :cm_retail_sales_sum_l4w, :cm_coupon_sum_l4w, :cm_sales_cost_sum_l4w, :cm_freight_in_sum_l4w,
                :cm_freight_out_sum_l4w, :cm_shipping_paid_by_customer_sum_l4w, :cm_shrink_sum_l4w,
                :cm_net_damages_sum_l4w, :cm_marked_out_of_stock_sum_l4w, :cm_markdown_reimbursement_sum_l4w,
                :cm_vendor_funded_allowances_sum_l4w, :cm_net_sales_retail_sum_l4w, :cm_cost_sum_l4w

        module Decorations
          include Transform::Transformers::Margin
        end
      end
    end
  end
end
