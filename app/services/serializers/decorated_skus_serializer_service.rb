module Serializers
  class DecoratedSkusSerializerService
    def initialize(product)
      raise ArgumentError, 'Must specify a product' if product.blank?

      @product = product
    end

    def decorated_skus
      @_decorated_skus ||= build_decorated_skus
    end

    def concept_skus_iterator_uniq(&block)
      concept_skus_iterator(&block).uniq
    end

    def concept_skus_iterator
      decorated_skus.map do |s|
        s.concept_skus.map do |cs|
          val = yield cs
          val if val # rubocop:disable Style/UnneededCondition
        end.compact
      end.flatten.compact
    end

    def concept_skus_any?(&block)
      decorated_skus.flat_map(&:concept_skus).any?(&block)
    end

    def field_values(field_sym)
      concept_skus_iterator do |cs|
        cs.public_send(field_sym)
      end.sort
    end

    def field_unique_values(field_sym)
      concept_skus_iterator_uniq do |cs|
        cs.public_send(field_sym)
      end
    end

    def sku_pricing_field_values(field_sym)
      concept_skus_iterator do |cs|
        cs.concept_sku_pricing&.public_send(field_sym)
      end.sort
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
