module Transform
  module Transformers
    module XPDM
      class SiteNavigation < CatalogTransformer::Base
        source_name 'External::XPDM::BBBYSiteNavigation'
        references :root_tree_node
        references :branch_tree_node
        references :leaf_tree_node

        exclude :item_id, :item_type
      end
    end
  end
end
