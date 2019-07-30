## These Serializers are on the way OUT to SOLR
## They are active record model serializers but do so
## in a way thay they can be written to our SOLR index.
module SOLR
  class ProductSerializer < BaseSerializer # rubocop:disable ClassLength
    include SOLR::Decorators::AnyDecoratedAttribute
    include SOLR::Decorators::ConceptSkuDetectDecoratedAttribute
    include SOLR::Decorators::ConceptSkuUniqDecoratedAttribute
    include SOLR::Decorators::ConceptSkuUniqDecoratedBooleanAttribute
    include SOLR::Decorators::FieldUniqDecoratedAttribute
    include SOLR::Decorators::PricingDecoratedAttribute
    include SOLR::Decorators::SkuUniqDecoratedAttribute
    include SOLR::Decorators::SkuAnyDecoratedAttribute
    include SOLR::Decorators::TreeNodeDecoratedAttribute
    include SOLR::Decorators::ConstantAttributeBuckets

    attribute :id
    attribute :skus, key: :_childDocuments_

    ProductCoreFields.product_fields.map do |field|
      attribute field.source_name, key: field.name
    end

    # these attributes do not exist
    stub_attributes :allow_exposure, :vintage

    decorate_concept_sku_uniq 'brand_id', field: 'concept_brand_id'
    decorate_concept_sku_uniq 'brand_name', field: 'display_brand'
    decorate_concept_sku_uniq 'sku_id', field: 'sku_id'

    # return true if one or more skus for the product evaluate to true
    decorate_sku_any 'vdc_sku', field: 'vdc_sku'

    decorate_concepts_for_true_concept_sku_boolean 'tbs_blocked', field: 'tbs_blocked'

    # can't use the groupings because these are defined by the serializer (below)
    decorate_sku_uniq 'units_sold_last_week', field: 'units_sold_last_1_week_online'
    decorate_sku_uniq 'units_sold_last_4_weeks', field: 'units_sold_last_4_weeks_online'
    decorate_sku_uniq 'units_sold_last_8_weeks', field: 'units_sold_last_8_weeks_online'
    decorate_sku_uniq 'units_sold_last_year', field: 'units_sold_last_52_weeks_online'
    decorate_sku_uniq 'chain_status', field: 'chain_status'
    decorate_sku_uniq 'promo_attribute', field: 'unique_sorted_promo_attribute'
    decorate_sku_uniq 'promo_attribute_name', field: 'unique_sorted_promo_attribute_name'

    decorate_field_uniq 'exclusivity_tier', field: 'exclusivity_tier'
    decorate_field_uniq 'min_aad_offset_days', field: 'aad_min_offset_days', group: 'min'
    decorate_field_uniq 'max_aad_offset_days', field: 'aad_max_offset_days', group: 'max'
    decorate_field_uniq 'lead_time', field: 'lead_time'
    decorate_field_uniq 'min_lead_time', field: 'lead_time', group: 'min'
    decorate_field_uniq 'max_lead_time', field: 'lead_time', group: 'max'
    decorate_field_uniq 'shipping_method', field: 'shipping_methods'
    decorate_field_uniq 'web_flags_summary', field: 'web_flags_summary'

    decorate_pricing 'margin_amount_cents', field: 'margin_amount', format: 'currency_cents'
    decorate_pricing 'price_cents', field: 'retail_price', format: 'currency_cents'
    decorate_pricing 'min_price_cents', field: 'retail_price', group: 'min', format: 'currency_cents'
    decorate_pricing 'max_price_cents', field: 'retail_price', group: 'max', format: 'currency_cents'
    decorate_pricing 'avg_margin_percent', field: 'margin_percent', group: 'avg'

    # contribution margin
    decorate_pricing 'contribution_margin_amount_cents', field: 'contribution_margin_amount', format: 'currency_cents'
    decorate_pricing 'contribution_margin_percent', field: 'contribution_margin_percent', format: 'percent_units'

    decorate_sku_uniq 'pdp_url', field: 'pdp_urls'
    decorate_sku_uniq 'vendor_id', field: 'vendor_id'
    decorate_sku_uniq 'vendor_name', field: 'vendor_name'
    decorate_sku_uniq 'personalization_name', field: 'set_personalization'
    decorate_sku_uniq 'web_status_buyer_reviewed', field: 'web_status_buyer_reviewed'
    decorate_sku_uniq 'web_status_in_progress', field: 'web_status_in_progress'
    decorate_sku_uniq 'web_status_active', field: 'web_status_active'
    decorate_sku_uniq 'web_status_suspended', field: 'web_status_suspended'
    decorate_sku_uniq 'buyer_name', field: 'buyer_name'
    decorate_sku_uniq 'buyer_id', field: 'buyer_cd'

    # hierarchies
    %w[eph merch bbby_site_nav ca_site_nav baby_site_nav].map(&:to_s).each do |tree|
      %w[node_id source_code node_name].each do |field|
        decorate_tree_node "#{tree}_tree_#{field}", tree: tree, field: field.delete_prefix('node_')
      end
    end

    bucket 'web_flags_summary', CatModels::Constants::WebFlagsSummary

    def id
      "P#{object.product_id}"
    end

    def concept_id
      concept_ids = []
      service.concept_skus_iterator do |cs|
        concept_ids << cs.concept_id if include_concept?(cs, cs.concept_id)
      end
      concept_ids.uniq
    end

    def source_collection_id
      concept_collections = object.collection_memberships.map(&:collection_id).flat_map do |collection_id|
        concept_id.map do |concept_id|
          Indexer::ConceptCollectionCache.fetch(concept_id, collection_id)
        end
      end
      concept_collections.compact.map { |concept_collection| concept_collection[:source_collection_id] }.uniq
    end

    def skus
      result = []

      object.skus.each do |s|
        result << SOLR::SkuSerializer.new(s).as_json
      end

      result
    end

    def doc_type
      'product'
    end

    def name
      # take the first name of the concept product
      object.concept_products&.map(&:name)&.first
    end

    def source_product_id
      object.concept_products&.map(&:source_product_id)&.uniq
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

    # TODO: implement me
    def description
      ''
    end

    # TODO: implement me
    def long_description
      ''
    end

    # TODO: implement me
    def eph_category_id
      []
    end

    # TODO: implement me
    def eph_category_name
      ''
    end

    def color
      service.decorated_skus.map(&:color_family).uniq
    end

    # TODO: implement me
    def internal_color_family
      ''
    end

    # the sales data are not properties of the product; so we can just define them here
    def units_sold_last_1_week_online
      service.decorated_skus.map(&:units_sold_last_1_week_online).compact.sum
    end

    def units_sold_last_4_weeks_online
      service.decorated_skus.map(&:units_sold_last_4_weeks_online).compact.sum
    end

    def units_sold_last_8_weeks_online
      service.decorated_skus.map(&:units_sold_last_8_weeks_online).compact.sum
    end

    def units_sold_last_52_weeks_online
      service.decorated_skus.map(&:units_sold_last_52_weeks_online).compact.sum
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

    def live
      service.concept_skus_any?(&:live)
    end

    def inventory?
      service.concept_skus_any? do |cs|
        cs.total_avail_qty > 0
      end
    end

    private

    def apply_format(result, rollup_field)
      if rollup_field.currency_cents?
        as_currency_cents(result)
      elsif rollup_field.currency?
        as_currency(result)
      else
        result
      end
    end

    def include_concept?(concept_sku, concept_id)
      case concept_id
      when 1, 3 # bed bath and okl
        true
      when 2 # canada
        concept_sku.considered_for_canada?
      when 4 # baby
        concept_sku.offered?
      else
        false
      end
    end

    def service
      @service ||= Serializers::DecoratedSkusSerializerService.new(Serializers::ProductDecoratorWrapper.new(object))
    end
  end
end
