## These Serializers are on the way OUT to SOLR
## They are active record model serializers but do so
## in a way thay they can be written to our SOLR index.
module SOLR
  class SalesSerializer < ActiveModel::Serializer
    attribute :sku_id
    attribute :id
    attribute :order_count
    attribute :order_qty
    attribute :order_date
    attribute :sales_amount
  end
end
