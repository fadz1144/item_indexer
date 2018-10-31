module Serializers
  class ProductDecoratorWrapper
    def initialize(product)
      raise ArgumentError, 'Must specify a product' if product.blank?

      @product = product
    end

    def decorated_skus
      @decorated_skus ||= build_decorated_skus
    end

    def concept_items
      @product.concept_products
    end

    private

    def build_decorated_skus
      skus.map do |s|
        s.concept_skus.each do |cs|
          cs.extend(CatModels::ConceptSkuDecorator)
        end
        s.extend(CatModels::SkuDecorator)
      end
    end

    def skus
      # @product.skus
      @product.product_memberships.map(&:sku)
    end
  end
end
