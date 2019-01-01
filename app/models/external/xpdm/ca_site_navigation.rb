module External
  module XPDM
    class CASiteNavigation < ProductSiteNavigation
      default_scope { where(web_site_cd: 'CA') }
      belongs_to :product, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :ca_site_navigations
      belongs_to :collection, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :ca_site_navigations

      with_options SITE_NAV_OPTIONS do
        belongs_to :root_tree_node, -> { ca_site_nav }, foreign_key: :top_nav_node_info_cd
        belongs_to :branch_tree_node, -> { ca_site_nav }, foreign_key: :sub_nav_node_info_cd
        belongs_to :leaf_tree_node, -> { ca_site_nav }, foreign_key: :trd_nav_node_info_cd
      end
    end
  end
end
