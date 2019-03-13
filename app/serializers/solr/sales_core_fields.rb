module SOLR
  class SalesCoreFields
    def self.field(name, options)
      @fields << SOLR::FieldDefinition.new(name, options)
    end

    @fields = []

    field 'sku_id', type: 'plong'
    field 'order_count', type: 'pint'
    field 'order_qty', type: 'pint'
    field 'order_date', type: 'pdate'
    field 'sales_amount', type: 'pfloat'

    def self.all_fields
      @fields
    end
  end
end
