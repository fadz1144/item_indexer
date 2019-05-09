module Transform
  module Transformers
    module ECOM
      class SkuSales < CatalogTransformer::Base
        source_name 'External::ECOM::SkuSales'
        target_name 'CatModels::SkuSalesIncremental'
        match_keys :sku_id, source_key: :sku
        specified_attributes_only

        attribute :sku_id, source_name: :sku
        attribute :order_date, source_name: :order_dt
        attribute :origin_cd, source_name: :origin_cd
        attribute :reg_order_flag, source_name: :reg_order_flag
        attribute :order_count, source_name: :order_ct
        attribute :order_qty, source_name: :order_qty
        attribute :unit_cost, source_name: :unit_cost
        attribute :sales_amount, source_name: :sales_amt
        attribute :row_xng_date, source_name: :row_xng_dt
        attribute :discount_amount, source_name: :disc_amt
      end
    end
  end
end

# FROM estage table model:
#
# <External::ECOM::CountSummarySkuSales
#  sku: 15086076,
#  order_dt: "2017-11-20",
#  origin_cd: "MW2-2$BAB",
#  reg_order_flag: "Y",
#  order_ct: 1,
#  order_qty: 1,
#  unit_cost: 0.299e1,
#  sales_amt: 0.299e1,
#  row_xng_dt: "2017-11-21",
#  disc_amt: nil>,
#  #<External::ECOM::CountSummarySkuSales sku: 15086173,
#  order_dt: "2017-11-20",
#  origin_cd: "BBB2$BBB",
#  reg_order_flag: "N",
#  order_ct: 1,
#  order_qty: 1,
#  unit_cost: 0.499e1,
#  sales_amt: 0.499e1,
#  row_xng_dt: "2017-11-21",
#  disc_amt: nil>
#
# TO bridge catalog table:
#
# create table temp_feeds.sku_sales_by_day_and_origin_incremental
# (
#   sku_id bigint not null,
#   order_date timestamp not null,
#   origin_cd varchar(15) not null,
#   reg_order_flag char(1) default 'N' not null,
#   order_count integer default 0,
#   order_qty integer default 0,
#   unit_cost numeric(12,2) default 0,
#   sales_amount numeric(12,2),
#   row_xng_date timestamp,
#   discount_amount numeric(5,2)
# );
