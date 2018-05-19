module Serializers
  class SkuDecoratorWrapper
    def initialize(sku)
      raise ArgumentError, 'Must specify a sku' if sku.blank?

      @sku = sku
    end

    def decorated_skus
      @decorated_skus ||= build_decorated_skus
    end

    private

    def build_decorated_skus
      @sku.concept_skus.each { |cs| cs.extend(CatModels::ConceptSkuDecorator) }
      @sku.extend(CatModels::SkuDecorator)
      [@sku]
    end
  end
end
