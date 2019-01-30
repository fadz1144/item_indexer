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

    def decorated_skus_iterator_any(&block)
      decorated_skus_iterator(&block).any?
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
      merch: :merch_class_tree_node,
      bbby_site_nav: :site_nav_tree_node,
      ca_site_nav: :site_nav_tree_node,
      baby_site_nav: :site_nav_tree_node
    }.freeze
    CONCEPT_ID_MAPPING = {
      bbby_site_nav: 1,
      ca_site_nav: 2,
      baby_site_nav: 4
    }.freeze

    def tree_node_values(tree, field_sym)
      tree_node_sym = TREE_NODE_MAPPING[tree]
      if SKU_LEVEL_TREE_NODES.include?(tree)
        sku_level_tree_node_values(tree_node_sym, field_sym)
      else
        concept_id = CONCEPT_ID_MAPPING[tree]
        concept_skus_node_values(tree_node_sym, field_sym, concept_id)
      end
    end

    def which_concepts(&matcher)
      @wrapper.concept_items.select(&matcher).map(&:concept_id)
    end

    private

    def concept_skus_node_values(tree_node_sym, field_sym, concept_id)
      concept_skus_iterator do |cs|
        if cs.concept_id == concept_id
          hierarchy = hierarchy_for(cs, tree_node_sym)
          hierarchy&.map { |h| h[field_sym] }
        end
      end.flatten.compact.uniq
    end

    def sku_level_tree_node_values(tree_node_sym, field_sym)
      decorated_skus.map do |s|
        hierarchy = hierarchy_for(s, tree_node_sym)
        hierarchy&.map { |h| h[field_sym] }
      end.flatten.compact.uniq
    end

    def hierarchy_for(record, tree_node_sym)
      tree_node_id = record.public_send("#{tree_node_sym}_id")
      return [] if tree_node_id.nil?

      Indexer::TreeCache.fetch(tree_node_id)
    end
  end
end
