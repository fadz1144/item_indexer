module External
  module XPDM
    class MerchTreeView < External::XPDM::Base
      self.table_name = 'pdm_item_prod_info'
      default_scope do
        select(:mh_dept_cd, :mh_dept_name, :mh_sub_dept_cd, :mh_sub_dept_name, :mh_class_cd, :mh_class_name)
          .group(:mh_dept_cd, :mh_dept_name, :mh_sub_dept_cd, :mh_sub_dept_name, :mh_class_cd, :mh_class_name)
      end
      scope :ordered, -> { order(:mh_dept_cd, :mh_sub_dept_cd, :mh_class_cd) }

      alias_attribute :dept_cd, :mh_dept_cd
      alias_attribute :dept_name, :mh_dept_name
      alias_attribute :sub_dept_cd, :mh_sub_dept_cd
      alias_attribute :sub_dept_name, :mh_sub_dept_name
      alias_attribute :class_cd, :mh_class_cd
      alias_attribute :class_name, :mh_class_name

      def create_ts
        Time.zone.now
      end

      def update_ts
        Time.zone.now
      end

      def load_ts
        Time.zone.now
      end

      def full_sub_dept_cd
        (dept_cd.presence || 0) * 1_000 + (sub_dept_cd.presence || 0)
      end

      def full_class_cd
        full_sub_dept_cd * 1_000 + (class_cd.presence || 0)
      end
    end
  end
end
