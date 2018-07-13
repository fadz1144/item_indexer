module SOLR
  class ProductSerializer < ActiveModel::Serializer # rubocop:disable ClassLength
    attribute :id
    attribute :skus, key: :_childDocuments_

    ProductCoreFields.product_fields.map do |field|
      attribute field[:name].to_sym
    end

    delegate :product_id, to: :object

    def id
      "P#{product_id}"
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

    def category_id
      CatModels::CategoryCache.hierarchy_for(object.category&.category_id).map(&:id)
    end

    def category_name
      CatModels::CategoryCache.hierarchy_for(object.category&.category_id).map(&:name).uniq
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

    def min_price
      as_currency(service.sku_pricing_field_values(:retail_price).min)
    end

    def max_price
      as_currency(service.sku_pricing_field_values(:retail_price).max)
    end

    def min_margin_amount
      service.sku_pricing_field_values(:margin_amount).min
    end

    def max_margin_amount
      service.sku_pricing_field_values(:margin_amount).max
    end

    def min_price_cents
      as_currency_cents(service.sku_pricing_field_values(:retail_price).min)
    end

    def max_price_cents
      as_currency_cents(service.sku_pricing_field_values(:retail_price).max)
    end

    def min_margin_amount_cents
      as_currency_cents(service.sku_pricing_field_values(:margin_amount).min)
    end

    def max_margin_amount_cents
      as_currency_cents(service.sku_pricing_field_values(:margin_amount).max)
    end

    def avg_margin_percent
      margin_percents = service.sku_pricing_field_values(:margin_percent)
      margin_percents.empty? ? 0 : margin_percents.sum.fdiv(margin_percents.size)
    end

    def min_lead_time
      lead_time.min
    end

    def max_lead_time
      lead_time.max
    end

    def min_aad_offset_days
      service.field_unique_values(:aad_min_offset_days).min
    end

    def max_aad_offset_days
      service.field_unique_values(:aad_max_offset_days).max
    end

    def shipping_method
      service.field_unique_values(:shipping_method)
    end

    def exclusivity_tier
      service.field_unique_values(:exclusivity_tier)
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

    def has_inventory # rubocop:disable PredicateName
      service.concept_skus_any? do |cs|
        cs.total_avail_qty > 0
      end
    end

    def vendor_id
      service.concept_skus_iterator_uniq(&:concept_vendor_id)
    end

    def vendor_name
      service.concept_skus_iterator_uniq(&:concept_vendor_name).uniq
    end

    def brand_id
      service.concept_skus_iterator_uniq(&:concept_brand_id)
    end

    def brand_name
      service.concept_skus_iterator_uniq(&:display_brand)
    end

    private

    def lead_time
      service.field_unique_values(:lead_time)
    end

    def service
      @service ||= Serializers::DecoratedSkusSerializerService.new(Serializers::ProductDecoratorWrapper.new(object))
    end

    def as_currency(value, type: 'USD')
      "#{value},#{type}"
    end

    def as_currency_cents(value)
      return 0 unless value

      (value * 100.0).to_i
    end
  end
end
