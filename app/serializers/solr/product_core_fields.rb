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
    shared 'product_id', type: 'plong', multiValued: true
    shared 'source_product_id', type: 'string', multiValued: true
    shared 'sku_id', type: 'plong', multiValued: true
    shared 'category_id', type: 'plong', multiValued: true
    shared 'category_name', type: 'text_general', multiValued: true
    shared 'concept_id', type: 'pint', multiValued: true
    shared 'eph_category_id', type: 'plong', multiValued: true
    shared 'eph_category_name', type: 'text_general', multiValued: true
    shared 'vendor_id', type: 'plong', multiValued: true
    shared 'vendor_name', type: 'text_general', multiValued: true
    shared 'brand_id', type: 'plong', multiValued: true
    shared 'brand_name', type: 'text_general', multiValued: true
    shared 'color', type: 'string', multiValued: true
    shared 'description', type: 'text_general'
    shared 'long_description', type: 'text_general'
    shared 'exclusivity_tier', type: 'string', multiValued: true
    shared 'has_inventory', type: 'boolean', source_name: :inventory?
    shared 'internal_color_family', type: 'string', multiValued: true
    shared 'item_status', type: 'string', multiValued: true
    shared 'live', type: 'boolean'
    shared 'min_aad_offset_days', type: 'pint'
    shared 'max_aad_offset_days', type: 'pint'
    shared 'min_price_cents', type: 'pint'
    shared 'max_price_cents', type: 'pint'
    shared 'min_margin_amount_cents', type: 'pint'
    shared 'max_margin_amount_cents', type: 'pint'
    shared 'min_margin', type: 'pint'
    shared 'max_margin', type: 'pint'
    shared 'name', type: 'text_general'
    shared 'shipping_method', type: 'string', multiValued: true
    shared 'web_status', type: 'string', multiValued: true

    ## web flags summary fields
    shared 'web_flags_summary', type: 'string'
    shared 'web_flags_summary_live_on_site', type: 'pint', multiValued: true
    shared 'web_flags_summary_in_workflow', type: 'pint', multiValued: true
    shared 'web_flags_summary_suspended', type: 'pint', multiValued: true
    shared 'web_flags_summary_buyer_reviewed', type: 'pint', multiValued: true

    # solr_field_expansion
    shared 'allow_exposure', type: 'boolean'
    shared 'available_in_ca', type: 'boolean'
    shared 'clearance_status', type: 'string', multiValued: true
    shared 'concept_eligibility', type: 'pint', multiValued: true
    shared 'contribution_margin_percent', type: 'pfloat'
    shared 'dynamic_price_eligible', type: 'boolean'
    shared 'inactive_reason', type: 'string', multiValued: true
    shared 'inventory_ecom_us', type: 'pint'
    shared 'inventory_ecom_ca', type: 'pint'
    shared 'inventory_okl_branded', type: 'pint'
    shared 'inventory_okl_vintage', type: 'pint'
    shared 'inventory_ropis', type: 'pint'
    shared 'inventory_total', type: 'pint'
    shared 'inventory_store_total', type: 'pint'
    shared 'inventory_vdc_total', type: 'pint'
    shared 'jda_status', type: 'string', multiValued: true
    shared 'line_of_business', type: 'string', multiValued: true
    shared 'ltl_eligible', type: 'boolean'
    shared 'personalized', type: 'boolean'
    shared 'product_type', type: 'string', multiValued: true
    shared 'size', type: 'string', multiValued: true
    shared 'tbs_blocked', type: 'pint', multiValued: true
    shared 'units_sold_last_week', type: 'pint', source_name: 'units_sold_last_1_week'
    shared 'units_sold_last_4_weeks', type: 'pint'
    shared 'units_sold_last_8_weeks', type: 'pint'
    shared 'units_sold_last_year', type: 'pint', source_name: 'units_sold_last_52_weeks'
    shared 'vdc_flag', type: 'boolean', source_name: 'vdc_sku'
    shared 'vintage', type: 'boolean'
    shared 'web_enabled_date', type: 'pdate'

    # hierarchies
    shared 'eph_tree_node_id', type: 'plong', multiValued: true
    shared 'eph_tree_source_code', type: 'string', multiValued: true
    shared 'eph_tree_node_name', type: 'text_general', multiValued: true
    shared 'merch_tree_node_id', type: 'plong', multiValued: true
    shared 'merch_tree_source_code', type: 'string', multiValued: true
    shared 'merch_tree_node_name', type: 'text_general', multiValued: true
    shared 'bbby_site_nav_tree_node_id', type: 'plong', multiValued: true
    shared 'bbby_site_nav_tree_source_code', type: 'string', multiValued: true
    shared 'bbby_site_nav_tree_node_name', type: 'text_general', multiValued: true
    shared 'ca_site_nav_tree_node_id', type: 'plong', multiValued: true
    shared 'ca_site_nav_tree_source_code', type: 'string', multiValued: true
    shared 'ca_site_nav_tree_node_name', type: 'text_general', multiValued: true
    shared 'baby_site_nav_tree_node_id', type: 'plong', multiValued: true
    shared 'baby_site_nav_tree_source_code', type: 'string', multiValued: true
    shared 'baby_site_nav_tree_node_name', type: 'text_general', multiValued: true

    # contribution margin
    shared 'min_contribution_margin_amount_cents', type: 'pint'
    shared 'max_contribution_margin_amount_cents', type: 'pint'
    shared 'min_contribution_margin_percent', type: 'pfloat'
    shared 'max_contribution_margin_percent', type: 'pfloat'

    # PDP url
    shared 'pdp_url', type: 'string', multiValued: true

    #
    # sku-only fields
    #
    sku 'brand_code', type: 'string', multiValued: true
    sku 'commission_percent', type: 'pfloat'
    sku 'cost_cents', type: 'pint'
    sku 'dimensions', type: 'string', multiValued: true
    sku 'external_image_url', type: 'string', multiValued: true
    sku 'gtin', type: 'string'
    sku 'limited_qty', type: 'boolean'
    sku 'margin_percent', type: 'pfloat'
    sku 'msrp_cents', type: 'pint'
    sku 'on_order_qty', type: 'pint'
    sku 'owned_available', type: 'pint'
    sku 'pre_markdown_price_cents', type: 'pint'
    sku 'store_avail_qty', type: 'pint'
    sku 'total_avail_qty', type: 'pint'
    sku 'vendor_remaining', type: 'pint'
    sku 'upc_ean', type: 'plong'
    sku 'vdc_avail_qty', type: 'pint'
    sku 'vendor_sku', type: 'text_general'
    sku 'vmf', type: 'boolean'
    sku 'warehouse_avail_qty', type: 'pint'

    #
    # product-only fields
    #
    product 'avg_margin_percent', type: 'pfloat'
    product 'min_lead_time', type: 'pint'
    product 'max_lead_time', type: 'pint'

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
