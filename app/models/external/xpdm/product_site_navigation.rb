module External
  module XPDM
    # = Product Site Navigation
    #
    # The three site navigation classes needed to be split apart in order to do eager loading of the tree nodes. The
    # combination of (a) all the tree nodes being in a single table and (b) the foreign key there (source value) not
    # being unique across trees means ActiveRecord cannot eager load the bed bath tree nodes at the same time it loads
    # the baby tree nodes. By separating the classes, each belongs to can include a default scope with the tree Id.
    # With that in place, the tree nodes can be eager loaded.
    class ProductSiteNavigation < External::XPDM::Base
      self.table_name = 'pdm_item_web_info_nav_pry'

      SITE_NAV_OPTIONS = { class_name: 'CatModels::TreeNode', optional: true, primary_key: :source_code }.freeze

      # blank (aka zero) is okay, but if there is a code it must exist as a node
      def tree_nodes_valid?
        (root_tree_node.present? || top_nav_node_info_cd.zero?) &&
          (branch_tree_node.present? || sub_nav_node_info_cd.zero?) &&
          (leaf_tree_node.present? || trd_nav_node_info_cd.zero?)
      end
    end
  end
end
