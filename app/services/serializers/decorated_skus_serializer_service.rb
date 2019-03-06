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

    def concept_products_iterator
      decorated_skus_iterator do |ds|
        ds.products.map do |p|
          p.concept_products.map do |cp|
            yield cp
          end
        end
      end
    end

    def decorated_skus_iterator
      decorated_skus.flat_map { |s| yield s }.compact
    end

    def concept_skus_any?(&block)
      decorated_skus.flat_map(&:concept_skus).any?(&block)
    end

    def field_values(field_sym)
      concept_skus_iterator { |cs| cs.public_send(field_sym) }.sort
    end

    def field_unique_values(field_sym)
      concept_skus_iterator_uniq do |cs|
        cs.public_send(field_sym)
      end
    end

    def sku_pricing_field_values(field_sym)
      concept_skus_iterator do |cs|
        cs.concept_sku_pricing&.public_send(field_sym) unless cs.concept_id == 2 # exclude amounts on the CA concept sku
      end.sort
    end

    SKU_LEVEL_TREE_NODES = %i[eph merch].freeze
    CONCEPT_PRODUCT_LEVEL_TREE_NODES = %i[bbby_site_nav ca_site_nav baby_site_nav].freeze
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
      if SKU_LEVEL_TREE_NODES.include?(tree)
        sku_level_tree_node_values(TREE_NODE_MAPPING[tree], field_sym)
      elsif CONCEPT_PRODUCT_LEVEL_TREE_NODES.include?(tree)
        concept_products_node_values(CONCEPT_ID_MAPPING[tree], field_sym)
      else
        Rails.logger.error "tree_node_values for unsupported tree #{tree} (field #{field_sym})"
      end
    end

    def which_concepts(&matcher)
      @wrapper.concept_items.select(&matcher).map(&:concept_id)
    end

    private

    def sku_level_tree_node_values(tree_node_sym, field_sym)
      decorated_skus.map do |s|
        hierarchy = hierarchy_for(s, tree_node_sym)
        hierarchy&.map { |h| h[field_sym] }
      end.flatten.compact.uniq
    end

    def concept_products_node_values(concept_id, field_sym)
      concept_products_iterator do |cp|
        if cp.concept_id == concept_id
          cp.site_navigations.map do |sn|
            # since the tree cache is based on the leaf node, we ignore root_tree_node_id and branch_tree_node_id
            # this means we do not add the small number of site navigations (less than 1%) with null leaf nodes but
            # non-null root and/or branch nodes
            hierarchy = Indexer::TreeCache.fetch(sn.leaf_tree_node_id)
            hierarchy&.map { |h| h[field_sym] }
          end
        end
      end.flatten.compact.uniq
    end

    def hierarchy_for(record, tree_node_sym)
      tree_node_id = record.public_send("#{tree_node_sym}_id")
      return [] if tree_node_id.nil?
      Indexer::TreeCache.fetch(tree_node_id)
    end
  end
end
