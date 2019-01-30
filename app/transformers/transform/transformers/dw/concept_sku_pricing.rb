module Transform
  module Transformers
    module DW
      # I exist just to make sure you'll notice if you attempt to call this and expect to get back a symbol.
      class NoTargetKeyErrorObject; end
      class ConceptSkuPricing < CatalogTransformer::Base
        match_keys NoTargetKeyErrorObject.new, source_key: :compound_source_key
        source_name 'Inbound::DW::ContributionMarginFeed'
        attribute :cm_amount_sum_l4w, source_name: :cm_l4w
        attribute :cm_rate_l4w, source_name: :cm_rate_l4w
        attribute :cm_sales_units_sum_l4w, source_name: :sls_unit_l4w
        attribute :cm_retail_sales_sum_l4w, source_name: :sls_ret_l4w
        attribute :cm_coupon_sum_l4w, source_name: :coupon_l4w
        attribute :cm_sales_cost_sum_l4w, source_name: :sls_cost_l4w
        attribute :cm_freight_in_sum_l4w, source_name: :freight_in_l4w
        attribute :cm_freight_out_sum_l4w, source_name: :freight_out_l4w
        attribute :cm_shipping_paid_by_customer_sum_l4w, source_name: :ship_fee_coll_l4w
        attribute :cm_shrink_sum_l4w, source_name: :shrink_l4w
        attribute :cm_net_damages_sum_l4w, source_name: :rtv_da_l4w
        attribute :cm_marked_out_of_stock_sum_l4w, source_name: :rtv_mos_l4w
        attribute :cm_markdown_reimbursement_sum_l4w, source_name: :md_reimb_l4w
        attribute :cm_vendor_funded_allowances_sum_l4w, source_name: :vend_supp_l4w
        # For the future - and when adding these in, remember to remove them from end of the exclude below
        # attribute :cm_net_sales_retail_sum_l4w, source_name: tbd
        # attribute :cm_cost_sum_l4w, source_name: tbd

        exclude :concept_sku_id, :concept_id, :source_sku_id, :retail_price, :cost, :pre_markdown_price,
                :margin_amount, :margin_percent, :map_price, :source_created_by, :source_created_at, :source_updated_by,
                :source_updated_at, :created_at, :updated_at, :contribution_margin_amount, :contribution_margin_percent,
                :cm_net_sales_retail_sum_l4w, :cm_cost_sum_l4w

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

        # module Decorations
        # end
      end
    end
  end
end
