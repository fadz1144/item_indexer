module External
  module XPDM
    class BBBYSiteNavigation < ProductSiteNavigation
      default_scope { where(web_site_cd: 'BBBY') }
      belongs_to :product, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :bbby_site_navigation

      with_options SITE_NAV_OPTIONS do
        belongs_to :site_nav_tree_node, -> { bbby_site_nav }
      end
    end
  end
end
