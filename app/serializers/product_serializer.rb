class ProductSerializer < ActiveModel::Serializer
  attributes :product_id, :category, :color, :image, :name, :min_price, :max_price, :min_lead_time, :max_lead_time,
             :lead_time, :min_aad_offset_days, :max_aad_offset_days, :vendor, :brand,
             :min_margin_amount, :max_margin_amount, :avg_margin_percent, :shipping_method, :exclusivity_tier

  has_many :skus, serializer: SkuSerializer, key: :sku

  def name
    # take the first name of the concept product
    object.concept_products&.map(&:name)&.first
  end

  def category
    hierarchy = CatModels::CategoryCache.hierarchy_for(object.category&.category_id)
    hierarchy.each_with_object({}) do |c, acc|
      acc["level_#{c.level}_category".to_sym] = cat_as_json(c)
    end
  end

  def color
    service.decorated_skus.each_with_object(Set.new) do |s, acc|
      acc.add(s.color_family)
    end.to_a
  end

  def image
    service.decorated_skus.each_with_object({}) do |s, acc|
      image_url = best_sku_image_url(s)
      if image_url.present?
        acc[:default] ||= image_url
        acc[s.color_family] ||= image_url if s.color_family.present?
      end
    end
  end

  def min_price
    service.sku_pricing_field_values(:retail_price).min
  end

  def max_price
    service.sku_pricing_field_values(:retail_price).max
  end

  def min_margin_amount
    service.sku_pricing_field_values(:margin_amount).min
  end

  def max_margin_amount
    service.sku_pricing_field_values(:margin_amount).max
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

  def lead_time
    service.field_unique_values(:lead_time)
  end

  def shipping_method
    service.field_unique_values(:shipping_method)
  end

  def exclusivity_tier
    service.field_unique_values(:exclusivity_tier)
  end

  def vendor
    service.concept_skus_iterator_uniq do |cs|
      { id: cs.concept_vendor_id, name: cs.concept_vendor_name }
    end
  end

  def brand
    service.concept_skus_iterator_uniq do |cs|
      { id: cs.concept_brand_id, name: cs.concept_brand_name }
    end
  end

  private

  def service
    @_service ||= Serializers::DecoratedSkusSerializerService.new(object)
  end

  def best_sku_image_url(decorated_sku)
    decorated_sku.concept_skus&.detect(&:primary_image)&.primary_image
  end

  def cat_as_json(category)
    category.as_json
  end
end
