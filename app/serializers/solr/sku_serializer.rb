## These Serializers are on the way OUT to SOLR
## They are active record model serializers but do so
## in a way thay they can be written to our SOLR index.
module SOLR
  class SkuSerializer < BaseSerializer # rubocop:disable ClassLength
    include SOLR::Decorators::AnyDecoratedAttribute
    include SOLR::Decorators::ConceptSkuDetectDecoratedAttribute
    include SOLR::Decorators::ConceptSkuUniqDecoratedAttribute
    include SOLR::Decorators::ConceptSkuUniqDecoratedBooleanAttribute
    include SOLR::Decorators::FieldUniqDecoratedAttribute
    include SOLR::Decorators::PricingDecoratedAttribute
    include SOLR::Decorators::SkuUniqDecoratedAttribute
    include SOLR::Decorators::TreeNodeDecoratedAttribute
    include SOLR::Decorators::ConstantAttributeBuckets

    attribute :id
    ProductCoreFields.sku_fields.map do |field|
      attribute field.source_name, key: field.name
    end

    # these attributes do not exist
    stub_attributes :brand_code

    decorate_any 'live', field: 'live'

    decorate_concept_sku_uniq 'brand_id', field: 'concept_brand_id'
    decorate_concept_sku_uniq 'brand_name', field: 'display_brand'
    decorate_concept_sku_uniq 'description', field: 'description'

    decorate_concept_sku_detect 'name', field: 'name'
    decorate_concept_sku_detect 'external_image_url', field: 'primary_image'

    decorate_concepts_for_true_concept_sku_boolean 'tbs_blocked', field: 'tbs_blocked'

    decorate_field_uniq 'concept_id', field: 'concept_id'
    decorate_field_uniq 'exclusivity_tier', field: 'exclusivity_tier'
    decorate_field_uniq 'limited_qty', field: 'limited_qty', group: 'first'
    decorate_field_uniq 'min_aad_offset_days', field: 'aad_min_offset_days', group: 'min'
    decorate_field_uniq 'max_aad_offset_days', field: 'aad_max_offset_days', group: 'max'
    decorate_field_uniq 'on_order_qty', field: 'on_order_qty', group: 'max'
    decorate_field_uniq 'shipping_method', field: 'shipping_methods'
    decorate_field_uniq 'store_avail_qty', field: 'stores_avail_qty', group: 'max'
    decorate_field_uniq 'total_avail_qty', field: 'total_avail_qty', group: 'max'
    decorate_field_uniq 'vdc_avail_qty', field: 'vdc_avail_qty', group: 'max'
    decorate_field_uniq 'vendor_sku', field: 'vendor_sku', group: 'max'
    decorate_field_uniq 'warehouse_avail_qty', field: 'warehouse_avail_qty', group: 'max'

    decorate_pricing 'cost', field: 'cost', group: 'max'
    decorate_pricing 'cost_cents', field: 'cost', group: 'max', format: 'currency_cents'
    decorate_pricing 'margin_percent', field: 'margin_percent', group: 'max'
    decorate_pricing 'price_cents', field: 'retail_price', format: 'currency_cents'
    decorate_pricing 'min_price_cents', field: 'retail_price', group: 'min', format: 'currency_cents'
    decorate_pricing 'max_price_cents', field: 'retail_price', group: 'max', format: 'currency_cents'

    decorate_pricing 'margin_amount_cents', field: 'margin_amount', format: 'currency_cents'
    decorate_pricing 'contribution_margin_amount_cents', field: 'contribution_margin_amount', format: 'currency_cents'
    decorate_pricing 'pre_markdown_price', field: 'pre_markdown_price', group: 'max'
    decorate_pricing 'pre_markdown_price_cents', field: 'pre_markdown_price', group: 'max', format: 'currency_cents'

    # contribution margin
    decorate_pricing 'contribution_margin_percent', field: 'contribution_margin_percent', format: 'percent_units'

    # fetch directly from the sku
    decorate_sku_uniq 'pdp_url', field: 'pdp_urls'
    decorate_sku_uniq 'vendor_id', field: 'vendor_id'
    decorate_sku_uniq 'vendor_name', field: 'vendor_name'
    decorate_sku_uniq 'units_sold_last_week', field: 'units_sold_last_1_week', group: 'sum'
    decorate_sku_uniq 'units_sold_last_4_weeks', field: 'units_sold_last_4_weeks', group: 'sum'
    decorate_sku_uniq 'units_sold_last_8_weeks', field: 'units_sold_last_8_weeks', group: 'sum'
    decorate_sku_uniq 'units_sold_last_year', field: 'units_sold_last_52_weeks', group: 'sum'
    decorate_sku_uniq 'color', field: 'color_family'

    # hierarchies
    %w[eph merch bbby_site_nav ca_site_nav baby_site_nav].map(&:to_s).each do |tree|
      %w[node_id source_code node_name].each do |field|
        decorate_tree_node "#{tree}_tree_#{field}", tree: tree, field: field.delete_prefix('node_')
      end
    end

    bucket 'web_flags_summary', CatModels::Constants::WebFlagsSummary

    def id
      "S#{object.sku_id}"
    end

    def product_id
      object.product_ids
    end

    def source_product_id
      object.products&.flat_map(&:concept_products)&.map(&:source_product_id)&.uniq
    end

    def doc_type
      'sku'
    end

    def upc_ean
      object.gtin
    end

    # TODO: implement me
    def long_description
      ''
    end

    def owned_available
      store_avail_qty + warehouse_avail_qty
    end

    def vendor_remaining
      vdc_avail_qty
    end

    # TODO: implement me
    def msrp
      0
    end

    # TODO: implement me
    def msrp_cents
      0
    end

    # TODO: implement me
    def commission_percent
      0
    end

    def category_id
      CatModels::CategoryCache.hierarchy_for(object.category&.category_id).map(&:id)
    end

    def category_name
      CatModels::CategoryCache.hierarchy_for(object.category&.category_id).map(&:name).uniq
    end

    def category_source_code
      CatModels::CategoryCache.hierarchy_for(object.category&.category_id).map(&:source_code).map(&:to_s).uniq
    end

    def source_collection_id
      products = object.products || []
      memberships = products.flat_map(&:collection_memberships) || []
      concept_collections = memberships.map(&:collection_id).flat_map do |collection_id|
        concept_id.map do |concept_id|
          Indexer::ConceptCollectionCache.fetch(concept_id, collection_id)
        end
      end || []
      concept_collections.compact.map { |concept_collection| concept_collection[:source_collection_id] }.uniq
    end

    # TODO: implement me
    def eph_category_id
      []
    end

    # TODO: implement me
    def eph_category_name
      ''
    end

    def dimensions
      service.concept_skus_iterator_uniq(&:dimensions) || []
    end

    def inventory?
      total_avail_qty.present? && total_avail_qty > 0
    end

    # TODO: implement me
    def internal_color_family
      ''
    end

    def item_status
      # active
      if service.concept_skus_any? { |cs| cs.status == 'Active' }
        ['Active']
      elsif service.concept_skus_any? { |cs| cs.status == 'In Progress' }
        ['In Progress']
      else
        (['Suspended'] + service.field_unique_values(:suspended_reason)).flatten.uniq
      end
    end

    private

    def service
      @service ||= Serializers::DecoratedSkusSerializerService.new(Serializers::SkuDecoratorWrapper.new(object))
    end
  end
end
