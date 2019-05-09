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

    def self.concept_sku(name, options)
      CatModels::Concept::CODES.keys.each do |concept_code|
        concept_specific_field_name = CatModels::ConceptSpecificAttributes.field_name(concept_code, name)
        @sku_fields << SOLR::FieldDefinition.new(concept_specific_field_name, options)
      end
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
    shared 'category_source_code', type: 'text_general', multiValued: true
    shared 'concept_id', type: 'pint', multiValued: true
    shared 'source_collection_id', type: 'pint', multiValued: true
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
    shared 'price_cents', type: 'pint', multiValued: true
    shared 'margin_amount_cents', type: 'pint', multiValued: true
    shared 'min_price_cents', type: 'pint'
    shared 'max_price_cents', type: 'pint'
    shared 'name', type: 'text_general'
    shared 'shipping_method', type: 'string', multiValued: true

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

    # hierarchies
    %w[eph merch bbby_site_nav ca_site_nav baby_site_nav].each do |tree|
      {
        'node_id': 'plong',
        'source_code': 'string',
        'node_name': 'text_general'
      }.each do |field, type|
        shared "#{tree}_tree_#{field}", type: type, multiValued: true
      end
    end

    # contribution margin
    shared 'contribution_margin_amount_cents', type: 'pint', multiValued: true
    shared 'contribution_margin_percent', type: 'pfloat', multiValued: true

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

    # sku-only concept-level field
    concept_sku 'web_enable_date', type: 'pdate'
    concept_sku 'web_status', type: 'string'
    concept_sku 'web_flags_summary', type: 'string'


    #
    # product-only fields
    #
    product 'avg_margin_percent', type: 'pfloat'
    product 'min_lead_time', type: 'pint'
    product 'max_lead_time', type: 'pint'
    product 'lead_time', type: 'pint', multiValued: true

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
