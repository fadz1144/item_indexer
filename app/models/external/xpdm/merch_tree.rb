module External
  module XPDM
    class MerchTree < External::XPDM::Base
      self.table_name = 'pdm_lu_merch_hiery'

      scope :ordered, -> { order(:dept_cd, :sub_dept_cd, :class_cd) }

      def full_sub_dept_cd
        dept_cd * 1_000 + sub_dept_cd
      end

      def full_class_cd
        full_sub_dept_cd * 1_000 + class_cd
      end
    end
  end
end
