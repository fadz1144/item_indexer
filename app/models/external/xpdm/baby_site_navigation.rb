module External
  module XPDM
    class BABYSiteNavigation < ProductSiteNavigation
      default_scope { where(web_site_cd: 'BABY') }
      belongs_to :product, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :baby_site_navigation

      with_options SITE_NAV_OPTIONS do
        belongs_to :site_nav_tree_node, -> { baby_site_nav }
      end
    end
  end
end
