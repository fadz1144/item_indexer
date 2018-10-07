module External
  module XPDM
    class SiteNavigationTreeView < External::XPDM::Base
      self.table_name = 'pdm_item_web_info_nav_pry'
      default_scope { where.not(top_nav_node_info_cd: 0) }
      scope :ordered, -> { order("top_nav_node_info_cd, sub_nav_node_info_cd, #{trd_cd}") }

      alias_attribute :top_nav_node_info_name, :top_nav_node_name
      alias_attribute :sub_nav_node_info_name, :sub_nav_node_name
      alias_attribute :trd_nav_node_info_name, :trd_nav_node_name

      def self.sanitized
        select(field_list('as trd_nav_node_info_cd', 'as trd_nav_node_name'))
          .group(field_list)
      end

      def create_ts
        Time.zone.now
      end

      def update_ts
        Time.zone.now
      end

      def load_ts
        Time.zone.now
      end

      def self.field_list(trd_cd_alias = nil, trd_name_alias = nil)
        <<~SQL
          web_site_cd,
          top_nav_node_info_cd, top_nav_node_name
          , sub_nav_node_info_cd, sub_nav_node_name
          , #{trd_cd} #{trd_cd_alias}
          , decode(trd_nav_node_info_cd, sub_nav_node_info_cd, null, trd_nav_node_name) #{trd_name_alias}
        SQL
      end

      def self.trd_cd
        'decode(trd_nav_node_info_cd, sub_nav_node_info_cd, 0, trd_nav_node_info_cd)'
      end
    end
  end
end
