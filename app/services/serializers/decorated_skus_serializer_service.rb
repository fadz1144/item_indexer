module Serializers
  class DecoratedSkusSerializerService
    def initialize(wrapper)
      raise ArgumentError, 'Must specify a wrapper' if wrapper.blank?
      @wrapper = wrapper
    end

    def decorated_skus
      @wrapper.decorated_skus
    end

    def concept_skus_iterator_uniq(&block)
      concept_skus_iterator(&block).uniq
    end

    def decorated_skus_iterator_uniq(&block)
      decorated_skus_iterator(&block).uniq
    end

    def concept_skus_iterator
      decorated_skus.map do |s|
        s.concept_skus.map do |cs|
          yield cs
        end.compact
      end.flatten.compact
    end

    def decorated_skus_iterator
      decorated_skus.map do |s|
        yield s
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
  end
end
