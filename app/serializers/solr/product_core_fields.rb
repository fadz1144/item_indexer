module SOLR
  class ProductCoreFields
    SHARED_FIELDS = [
      { name: 'product_id', type: 'long', indexed: true, stored: true },
      { name: 'doc_type', type: 'string', indexed: true, stored: true },
      { name: 'category_id', type: 'long', indexed: true, stored: true, multiValued: true },
      { name: 'category_name', type: 'text_general', indexed: true, stored: true, multiValued: true },
      { name: 'concept_id', type: 'int', indexed: true, stored: true, multiValued: true },
      { name: 'eph_category_id', type: 'long', indexed: true, stored: true, multiValued: true },
      { name: 'eph_category_name', type: 'text_general', indexed: true, stored: true, multiValued: true },
      { name: 'vendor_id', type: 'long', indexed: true, stored: true, multiValued: true },
      { name: 'vendor_name', type: 'text_general', indexed: true, stored: true, multiValued: true },
      { name: 'brand_id', type: 'long', indexed: true, stored: true, multiValued: true },
      { name: 'brand_name', type: 'text_general', indexed: true, stored: true, multiValued: true },
      { name: 'color', type: 'string', indexed: true, stored: true, multiValued: true },
      { name: 'description', type: 'text_general', indexed: true, stored: true },
      { name: 'long_description', type: 'text_general', indexed: true, stored: true },
      { name: 'exclusivity_tier', type: 'string', indexed: true, stored: true, multiValued: true },
      { name: 'has_inventory', type: 'boolean', indexed: true, stored: true },
      { name: 'internal_color_family', type: 'string', indexed: true, stored: true, multiValued: true },
      { name: 'item_status', type: 'string', indexed: true, stored: true, multiValued: true },
      { name: 'live', type: 'boolean', indexed: true, stored: true },
      { name: 'min_aad_offset_days', type: 'int', indexed: true, stored: true },
      { name: 'max_aad_offset_days', type: 'int', indexed: true, stored: true },
      { name: 'min_price_cents', type: 'int', indexed: true, stored: true },
      { name: 'max_price_cents', type: 'int', indexed: true, stored: true },
      { name: 'min_margin_amount_cents', type: 'int', indexed: true, stored: true },
      { name: 'max_margin_amount_cents', type: 'int', indexed: true, stored: true },
      { name: 'name', type: 'text_general', indexed: true, stored: true },
      { name: 'shipping_method', type: 'string', indexed: true, stored: true, multiValued: true },
      ## web status fields
      { name: 'web_status', type: 'string', indexed: true, stored: true },
      { name: 'web_status_buyer_reviewed', type: 'int', indexed: true, stored: true },
      { name: 'web_status_in_progress', type: 'int', indexed: true, stored: true },
      { name: 'web_status_active', type: 'int', indexed: true, stored: true },
      { name: 'web_status_suspended', type: 'int', indexed: true, stored: true }
    ].freeze

    SKU_ONLY_FIELDS = [
      { name: 'sku_id', type: 'long', indexed: true, stored: true, multiValued: true },
      { name: 'brand_code', type: 'string', indexed: true, stored: true, multiValued: true },
      { name: 'commission_percent', type: 'float', indexed: true, stored: true },
      { name: 'cost_cents', type: 'int', indexed: true, stored: true },
      { name: 'dimensions', type: 'string', indexed: true, stored: true, multiValued: true },
      { name: 'external_image_url', type: 'string', indexed: true, stored: true, multiValued: true },
      { name: 'gtin', type: 'string', indexed: true, stored: true },
      { name: 'limited_qty', type: 'boolean', indexed: true, stored: true },
      { name: 'margin_percent', type: 'float', indexed: true, stored: true },
      { name: 'msrp_cents', type: 'int', indexed: true, stored: true },
      { name: 'on_order_qty', type: 'int', indexed: true, stored: true },
      { name: 'owned_available', type: 'int', indexed: true, stored: true },
      { name: 'pre_markdown_price_cents', type: 'int', indexed: true, stored: true },
      { name: 'store_avail_qty', type: 'int', indexed: true, stored: true },
      { name: 'total_avail_qty', type: 'int', indexed: true, stored: true },
      { name: 'vendor_remaining', type: 'int', indexed: true, stored: true },
      { name: 'upc_ean', type: 'long', indexed: true, stored: true },
      { name: 'vdc_avail_qty', type: 'int', indexed: true, stored: true },
      { name: 'vendor_sku', type: 'text_general', indexed: true, stored: true },
      { name: 'vmf', type: 'boolean', indexed: true, stored: true },
      { name: 'warehouse_avail_qty', type: 'int', indexed: true, stored: true }
    ].freeze

    PRODUCT_ONLY_FIELDS = [
      { name: 'avg_margin_percent', type: 'float', indexed: true, stored: true },
      { name: 'min_lead_time', type: 'int', indexed: true, stored: true },
      { name: 'max_lead_time', type: 'int', indexed: true, stored: true }
    ].freeze

    def self.product_fields
      SHARED_FIELDS + PRODUCT_ONLY_FIELDS
    end

    def self.sku_fields
      SHARED_FIELDS + SKU_ONLY_FIELDS
    end

    def self.all_fields
      SHARED_FIELDS + SKU_ONLY_FIELDS + PRODUCT_ONLY_FIELDS
    end
  end
end
