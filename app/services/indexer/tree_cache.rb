module Indexer
  class TreeCache
    def self.build(*tree_ids)
      new(tree_ids)
    end

    def self.fetch(tree_node_id)
      Rails.configuration.indexer_tree_cache.fetch(tree_node_id) { [] }
    end

    def initialize(tree_ids)
      cache = ActiveSupport::Cache::MemoryStore.new

      trees(tree_ids).each do |tree|
        tree.leaf_node_ids.each do |tree_node_id|
          cache.write(tree_node_id, tree.node_with_ancestors(tree_node_id).map { |n| node_to_h(n) })
        end
      end

      Rails.configuration.indexer_tree_cache = cache
    end

    private

    def trees(tree_ids)
      CatModels::Tree.includes(:tree_nodes).tap { |a| a.where!(tree_id: tree_ids) if tree_ids.present? }
    end

    def node_to_h(node)
      { id: node.tree_node_id,
        parent_id: node.parent_id,
        name: node.name,
        level: node.level,
        leaf: node.leaf }
    end
  end
end
