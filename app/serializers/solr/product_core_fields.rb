module SOLR
  # rubocop:disable ClassLength
  class ProductCoreFields
    def self.shared(name, options)
      @shared_fields << SOLR::FieldDefinition.new(name, options)
    end

    def self.product(name, options)
      @product_fields << SOLR::FieldDefinition.new(name, options)
    end

    def self.sku(name, options)
      @sku_fields << SOLR::FieldDefinition.new(name, options)
    end

    @shared_fields = []
    @product_fields = []
    @sku_fields = []

    shared 'doc_type', type: 'string'
    shared 'product_id', type: 'long', multiValued: true
    shared 'source_product_id', type: 'string', multiValued: true
    shared 'sku_id', type: 'long', multiValued: true
    shared 'category_id', type: 'long', multiValued: true
    shared 'category_name', type: 'text_general', multiValued: true
    shared 'concept_id', type: 'int', multiValued: true
    shared 'eph_category_id', type: 'long', multiValued: true
    shared 'eph_category_name', type: 'text_general', multiValued: true
    shared 'vendor_id', type: 'long', multiValued: true
    shared 'vendor_name', type: 'text_general', multiValued: true
    shared 'brand_id', type: 'long', multiValued: true
    shared 'brand_name', type: 'text_general', multiValued: true
    shared 'color', type: 'string', multiValued: true
    shared 'description', type: 'text_general'
    shared 'long_description', type: 'text_general'
    shared 'exclusivity_tier', type: 'string', multiValued: true
    shared 'has_inventory', type: 'boolean', source_name: :inventory?
    shared 'internal_color_family', type: 'string', multiValued: true
    shared 'item_status', type: 'string', multiValued: true
    shared 'live', type: 'boolean'
    shared 'min_aad_offset_days', type: 'int'
    shared 'max_aad_offset_days', type: 'int'
    shared 'min_price_cents', type: 'int'
    shared 'max_price_cents', type: 'int'
    shared 'min_margin_amount_cents', type: 'int'
    shared 'max_margin_amount_cents', type: 'int'
    shared 'min_margin', type: 'int'
    shared 'max_margin', type: 'int'
    shared 'name', type: 'text_general'
    shared 'shipping_method', type: 'string', multiValued: true
    shared 'web_status', type: 'string', multiValued: true

    ## web flags summary fields
    shared 'web_flags_summary', type: 'string'
    shared 'web_flags_summary_live_on_site', type: 'int', multiValued: true
    shared 'web_flags_summary_in_workflow', type: 'int', multiValued: true
    shared 'web_flags_summary_suspended', type: 'int', multiValued: true
    shared 'web_flags_summary_buyer_reviewed', type: 'int', multiValued: true

    # solr_field_expansion
    shared 'allow_exposure', type: 'boolean'
    shared 'available_in_ca', type: 'boolean'
    shared 'clearance_status', type: 'string', multiValued: true
    shared 'concept_eligibility', type: 'int', multiValued: true
    shared 'contribution_margin_percent', type: 'float'
    shared 'dynamic_price_eligible', type: 'boolean'
    shared 'inactive_reason', type: 'string', multiValued: true
    shared 'inventory_ecom_us', type: 'int'
    shared 'inventory_ecom_ca', type: 'int'
    shared 'inventory_okl_branded', type: 'int'
    shared 'inventory_okl_vintage', type: 'int'
    shared 'inventory_ropis', type: 'int'
    shared 'inventory_total', type: 'int'
    shared 'inventory_store_total', type: 'int'
    shared 'inventory_vdc_total', type: 'int'
    shared 'jda_status', type: 'string', multiValued: true
    shared 'line_of_business', type: 'string', multiValued: true
    shared 'ltl_eligible', type: 'boolean'
    shared 'personalized', type: 'boolean'
    shared 'product_type', type: 'string', multiValued: true
    shared 'size', type: 'string', multiValued: true
    shared 'tbs_blocked', type: 'int', multiValued: true
    shared 'units_sold_last_week', type: 'int', source_name: 'units_sold_last_1_week'
    shared 'units_sold_last_4_weeks', type: 'int'
    shared 'units_sold_last_8_weeks', type: 'int'
    shared 'units_sold_last_year', type: 'int', source_name: 'units_sold_last_52_weeks'
    shared 'vdc_flag', type: 'boolean', source_name: 'vdc_sku'
    shared 'vintage', type: 'boolean'
    shared 'web_enabled_date', type: 'date'

    # hierarchies
    shared 'eph_tree_node_id', type: 'long', multiValued: true
    shared 'eph_tree_source_code', type: 'string', multiValued: true
    shared 'eph_tree_node_name', type: 'text_general', multiValued: true
    shared 'merch_tree_node_id', type: 'long', multiValued: true
    shared 'merch_tree_source_code', type: 'string', multiValued: true
    shared 'merch_tree_node_name', type: 'text_general', multiValued: true
    shared 'bbby_site_nav_tree_node_id', type: 'long', multiValued: true
    shared 'bbby_site_nav_tree_source_code', type: 'string', multiValued: true
    shared 'bbby_site_nav_tree_node_name', type: 'text_general', multiValued: true
    shared 'ca_site_nav_tree_node_id', type: 'long', multiValued: true
    shared 'ca_site_nav_tree_source_code', type: 'string', multiValued: true
    shared 'ca_site_nav_tree_node_name', type: 'text_general', multiValued: true
    shared 'baby_site_nav_tree_node_id', type: 'long', multiValued: true
    shared 'baby_site_nav_tree_source_code', type: 'string', multiValued: true
    shared 'baby_site_nav_tree_node_name', type: 'text_general', multiValued: true

    # contribution margin
    shared 'min_contribution_margin_amount_cents', type: 'int'
    shared 'max_contribution_margin_amount_cents', type: 'int'
    shared 'min_contribution_margin_percent', type: 'float'
    shared 'max_contribution_margin_percent', type: 'float'

    # PDP url
    shared 'pdp_url', type: 'string', multiValued: true

    #
    # sku-only fields
    #
    sku 'brand_code', type: 'string', multiValued: true
    sku 'commission_percent', type: 'float'
    sku 'cost_cents', type: 'int'
    sku 'dimensions', type: 'string', multiValued: true
    sku 'external_image_url', type: 'string', multiValued: true
    sku 'gtin', type: 'string'
    sku 'limited_qty', type: 'boolean'
    sku 'margin_percent', type: 'float'
    sku 'msrp_cents', type: 'int'
    sku 'on_order_qty', type: 'int'
    sku 'owned_available', type: 'int'
    sku 'pre_markdown_price_cents', type: 'int'
    sku 'store_avail_qty', type: 'int'
    sku 'total_avail_qty', type: 'int'
    sku 'vendor_remaining', type: 'int'
    sku 'upc_ean', type: 'long'
    sku 'vdc_avail_qty', type: 'int'
    sku 'vendor_sku', type: 'text_general'
    sku 'vmf', type: 'boolean'
    sku 'warehouse_avail_qty', type: 'int'

    #
    # product-only fields
    #
    product 'avg_margin_percent', type: 'float'
    product 'min_lead_time', type: 'int'
    product 'max_lead_time', type: 'int'

    def self.product_fields
      @shared_fields + @product_fields
    end

    def self.sku_fields
      @shared_fields + @sku_fields
    end

    def self.all_fields
      @shared_fields + @sku_fields + @product_fields
    end
  end
  # rubocop:enable all
end
