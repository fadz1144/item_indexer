module External
  module XPDM
    class ProductTreeLoader
      def self.perform
        new(CatModels::Tree.find(1)).load
      end

      def initialize(tree = nil)
        @tree = tree || CatModels::Tree.new(name: 'Enterprise Product Hierarchy', source_created_at: Time.zone.now,
                                            source_updated_at: Time.zone.now)
      end

      def load
        source_nodes = External::XPDM::ProductTree.all
        level_one_nodes, children = source_nodes.partition(&:top_level?)
        @by_parent = children.group_by(&:parnt_node_id)

        level_one_nodes.each { |node| build_tree_node(node) }

        @tree.save!
      end

      private

      # rubocop:disable Metrics/AbcSize
      def build_tree_node(product_node, parent = nil)
        level = parent.present? ? parent.level + 1 : 1
        node_children = @by_parent.fetch(product_node.eph_prod_node_id, [])

        tree_node = @tree.tree_nodes.build(name: format_name(product_node.node_name), parent: parent, level: level,
                                           source_code: product_node.eph_prod_node_id, leaf: node_children.empty?,
                                           source_created_at: product_node.source_created_at,
                                           source_updated_at: product_node.source_updated_at)

        node_children.each { |child| build_tree_node(child, tree_node) }
      end
      # rubocop:enable Metrics/AbcSize

      def format_name(value)
        value.force_encoding('iso8859-1').encode('utf-8').delete("\u0000") if value.present?
      end
    end
  end
end
