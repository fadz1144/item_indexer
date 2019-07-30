module Transform
  module Transformers
    module SALES
      # I exist just to make sure you'll notice if you attempt to call this and expect to get back a symbol.
      class NoTargetKeyErrorObject; end
      class ConceptSkuPricing < CatalogTransformer::Base
        match_keys NoTargetKeyErrorObject.new, source_key: :compound_source_key
        source_name 'Inbound::DW::DwSalesMetricsFeed'
        attribute :total_sales_units_l1w, source_name: :total_sales_units_l1w
        attribute :total_sales_units_l8w, source_name: :total_sales_units_l8w
        attribute :total_sales_units_l52w, source_name: :total_sales_units_l52w

        exclude :concept_sku_id, :concept_id, :source_sku_id, :retail_price, :cost, :pre_markdown_price,
                :margin_amount, :margin_percent, :map_price, :source_created_by, :source_created_at, :source_updated_by,
                :source_updated_at, :created_at, :updated_at, :contribution_margin_amount, :contribution_margin_percent,
                :cm_net_sales_retail_sum_l4w, :cm_cost_sum_l4w, :cm_l52w_updated_at, :cm_l4w_updated_at,
                :cm_vendor_funded_allowances_sum_l4w, :cm_markdown_reimbursement_sum_l4w,
                :cm_marked_out_of_stock_sum_l4w, :cm_net_damages_sum_l4w, :cm_shrink_sum_l4w,
                :cm_shipping_paid_by_customer_sum_l4w, :cm_freight_out_sum_l4w, :cm_freight_in_sum_l4w,
                :cm_sales_cost_sum_l4w, :cm_coupon_sum_l4w, :cm_retail_sales_sum_l4w, :cm_sales_units_sum_l4w,
                :cm_rate_l4w, :cm_amount_sum_l4w, :cm_amount_sum_l52w, :cm_rate_l52w,
                :cm_sales_units_sum_l52w, :cm_retail_sales_sum_l52w, :cm_coupon_sum_l52w, :cm_sales_cost_sum_l52w,
                :cm_freight_in_sum_l52w, :cm_freight_out_sum_l52w, :cm_shipping_paid_by_customer_sum_l52w,
                :cm_shrink_sum_l52w, :cm_net_damages_sum_l52w, :cm_marked_out_of_stock_sum_l52w,
                :cm_markdown_reimbursement_sum_l52w, :cm_vendor_funded_allowances_sum_l52w,
                :cm_net_sales_retail_sum_l52w, :cm_cost_sum_l52w, :cm_amount_l52w, :cm_retail_sales_l52w,
                :cm_coupon_l52w, :cm_sales_cost_l52w, :cm_freight_in_l52w, :cm_freight_out_l52w,
                :cm_shipping_paid_by_customer_l52w, :cm_shrink_l52w, :cm_net_damages_l52w, :cm_marked_out_of_stock_l52w,
                :cm_markdown_reimbursement_l52w, :cm_vendor_funded_allowances_l52w, :cm_net_sales_retail_l52w,
                :cm_cost_l52w

        # if these are added to the feed, then remove all this in favor of mapping
        CALCULATED_LAST_FOUR_WEEK =
          %i[cm_amount_l4w cm_retail_sales_l4w cm_coupon_l4w cm_sales_cost_l4w cm_freight_in_l4w cm_freight_out_l4w
             cm_shipping_paid_by_customer_l4w cm_shrink_l4w cm_net_damages_l4w cm_marked_out_of_stock_l4w
             cm_markdown_reimbursement_l4w cm_vendor_funded_allowances_l4w cm_net_sales_retail_l4w cm_cost_l4w].freeze
        exclude(*CALCULATED_LAST_FOUR_WEEK)

        def self.source_relation
          super.order(:id)
        end

        def self.load_indexed_targets(source_records)
          all_records = {}
          # Group source records by concept_id
          #   and for each concept they represent:
          source_records.group_by(&:concept_id).each do |concept_id, records|
            # Get all the target records and index them by the compound source key
            #          (see Inbound::DW::ContributionMarginFeed#compound_source_key for format)
            sku_ids = records.map(&:sku_id)
            this_concept_target_records = target_relation
                                          .where(concept_id: concept_id, sku_id: sku_ids)
                                          .to_a
                                          .index_by { |sku_pricing| compound_target_key(sku_pricing) }
            # Append them onto all_records
            all_records.merge!(this_concept_target_records)
          end
          all_records
        end

        def self.compound_target_key(object)
          '%d:%d' % [object.concept_id, object.sku_id]
        end
      end
    end
  end
end
