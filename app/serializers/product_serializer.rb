
class ProductSerializer < ActiveModel::Serializer
  attributes :product_id, :category, :color, :image

  belongs_to :brand, serializer: BrandSerializer
  has_many :skus, serializer: SkuSerializer, key: :sku

  def category
    hierarchy = CatModels::CategoryCache.hierarchy_for(object.category.category_id)
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

  private

  def best_sku_image_url(decorated_sku)
    decorated_sku.concept_skus&.detect(&:primary_image)
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

  # def all_sku_data
  #   return @all_sku_data unless @all_sku_data.nil?
  #   object.skus.each do |sku|
  #     @all_sku_data[:colors] ||= []
  #     @all_sku_data[:colors] << sku.color
  #   end
  #
  # end
end
