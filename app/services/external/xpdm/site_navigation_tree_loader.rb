module External
  module XPDM
    class SiteNavigationTreeLoader
      def self.perform
        new.load
      end

      def initialize(trees = nil)
        @trees = trees || {
          BBBY: build_tree('Bed Bath Site Navigation'),
          CA: build_tree('Canada Site Navigation'),
          BABY: build_tree('Baby Site Navigation')
        }
      end

      def load
        @trees.each do |web_site_cd, tree|
          @tree_nodes = tree.tree_nodes
          @current_top = nil
          @current_sub = nil

          build_tree_nodes(web_site_cd)

          tree.save!
        end
      end

      private

      def build_tree(name)
        CatModels::Tree.new(name: name, source_created_at: Time.zone.now, source_updated_at: Time.zone.now)
      end

      def build_tree_nodes(web_site_cd)
        External::XPDM::SiteNavigationTreeView.ordered.sanitized.where(web_site_cd: web_site_cd).all.each do |node|
          build_top(node)
          build_sub(node)
          build_trd(node)
        end
      end

      def build_top(node)
        return if node.top_nav_node_info_cd.to_s == @current_top&.source_code

        @current_top = build(node,
                             name: node.top_nav_node_info_name,
                             level: 1,
                             source_code: node.top_nav_node_info_cd,
                             leaf: false)
      end

      # the sub node can have products as well as trd nodes, so the leaf value here is not super helpful
      def build_sub(node)
        return if node.sub_nav_node_info_cd.to_s == @current_sub&.source_code || node.sub_nav_node_info_cd.zero?

        @current_sub = build(node,
                             name: node.sub_nav_node_info_name,
                             level: 2,
                             source_code: node.sub_nav_node_info_cd,
                             parent: @current_top,
                             leaf: false)
      end

      def build_trd(node)
        return if node.trd_nav_node_info_cd.zero?
        build(node,
              name: node.trd_nav_node_info_name,
              level: 3,
              source_code: node.trd_nav_node_info_cd,
              parent: @current_sub,
              leaf: true)
      end

      def build(node, attributes)
        @tree_nodes.build(attributes.merge(source_created_at: node.source_created_at,
                                           source_updated_at: node.source_updated_at))
      end
    end
  end
end
