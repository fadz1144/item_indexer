
class ProductSerializer < ActiveModel::Serializer
  attributes :product_id, :category, :color, :image, :name, :min_price, :max_price, :min_lead_time, :max_lead_time,
             :lead_time, :min_aad_offset_days, :max_aad_offset_days,
             :min_margin_amount, :max_margin_amount, :avg_margin_percent, :shipping_method

  belongs_to :brand, serializer: BrandSerializer
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
    colors = Set.new
    decorated_skus.each do |s|
      colors.add(s.color_family)
    end
    colors.to_a
  end

  def image
    decorated_skus.each_with_object({}) do |s, acc|
      image_url = best_sku_image_url(s)
      if image_url.present?
        acc[:default] ||= image_url
        acc[s.color_family] ||= image_url if s.color_family.present?
      end
    end
  end

  def min_price
    sku_pricing_field_values(:retail_price).min
  end

  def max_price
    sku_pricing_field_values(:retail_price).max
  end

  def min_margin_amount
    sku_pricing_field_values(:margin_amount).min
  end

  def max_margin_amount
    sku_pricing_field_values(:margin_amount).max
  end

  def avg_margin_percent
    margin_percents = sku_pricing_field_values(:margin_percent)
    margin_percents.empty? ? 0 : margin_percents.sum.fdiv(margin_percents.size)
  end

  def min_lead_time
    lead_time.min
  end

  def max_lead_time
    lead_time.max
  end

  def min_aad_offset_days
    concept_sku_field_values(:aad_min_offset_days).min
  end

  def max_aad_offset_days
    concept_sku_field_values(:aad_max_offset_days).max
  end

  def lead_time
    concept_sku_field_values(:lead_time)
  end

  def shipping_method
    shipping_methods = Set.new
    decorated_skus.each do |s|
      sm = s.concept_skus&.map(&:shipping_method)&.uniq
      sm&.each { |m| shipping_methods.add(m) }
    end
    shipping_methods.to_a
  end

  private

  def sku_pricing_field_values(field_sym)
    decorated_skus.each_with_object([]) do |s, arr|
      s.concept_skus&.each do |cs|
        value = cs.concept_sku_pricing&.send(field_sym)
        arr << value if value
      end
    end.sort
  end

  def concept_sku_field_values(field_sym)
    decorated_skus.each.with_object([]) do |s, acc|
      s.concept_skus&.each do |cs|
        val = cs.send(field_sym)
        acc << val if val
      end
    end.sort
  end

  def best_sku_image_url(decorated_sku)
    decorated_sku.concept_skus&.detect(&:primary_image)&.primary_image
  end

  def cat_as_json(category)
    # options = {}
    # serialization = ActiveModelSerializers::SerializableResource.new(category, options)
    # serialization.as_json
    category.as_json
  end

  # TODO: I wouldn't expect this to be needed, but it doesn't seem like the block gets called in the has_many
  def decorated_skus
    object.skus.map do |s|
      s.concept_skus.each do |cs|
        cs.extend(CatModels::ConceptSkuDecorator)
      end
      s.extend(CatModels::SkuDecorator)
    end
  end
end
