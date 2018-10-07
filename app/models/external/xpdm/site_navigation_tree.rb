module External
  module XPDM
    class SiteNavigationTree < External::XPDM::Base
      self.table_name = :pdm_lu_web_nav_hry
      scope :ordered, -> { order(:top_nav_node_info_cd, :sub_nav_node_info_cd, :trd_nav_node_info_cd) }

      def self.sanitized
        select(
          <<~SQL
            top_nav_node_info_cd, top_nav_node_info_name
            , sub_nav_node_info_cd, sub_nav_node_info_name
            , decode(trd_nav_node_info_cd, sub_nav_node_info_cd, 0, trd_nav_node_info_cd) as trd_nav_node_info_cd
            , decode(trd_nav_node_info_cd, sub_nav_node_info_cd, null, trd_nav_node_info_name) as trd_nav_node_info_name
            , create_ts, update_ts, load_ts
        SQL
        )
      end
    end
  end
end
