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

    SKU_LEVEL_TREE_NODES = %i[eph merch].freeze
    CONCEPT_SKU_LEVEL_TREE_NODES = %i[bbby_site_nav ca_site_nav baby_site_nav].freeze
    TREE_NODE_MAPPING = {
      eph: :eph_tree_node,
      merch: :merch_class_tree_node
    }.freeze
    def tree_node_values(tree, field_sym)
      tree_node_sym = TREE_NODE_MAPPING[tree]
      if SKU_LEVEL_TREE_NODES.include?(tree)
        sku_level_tree_node_values(tree_node_sym, field_sym)
      else
        concept_skus_node_values(tree_node_sym, field_sym)
      end
    end

    private

    def concept_skus_node_values(tree_node_sym, field_sym)
      concept_skus_iterator do |cs|
        tree_node = cs.public_send(tree_node_sym)
        tree_node&.map(&field_sym)
      end.flatten.compact
    end

    def sku_level_tree_node_values(tree_node_sym, field_sym)
      decorated_skus.map do |s|
        tree_node = s.public_send(tree_node_sym)
        hierarchy = hierarchy_for(tree_node)
        hierarchy&.map { |h| h[field_sym] }
      end.flatten.compact.uniq
    end

    def hierarchy_for(tree_node)
      return [] if tree_node.nil?

      Indexer::TreeCache.fetch(tree_node.tree_node_id)
    end
  end
end
