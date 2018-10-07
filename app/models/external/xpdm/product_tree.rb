module External
  module XPDM
    class ProductTree < External::XPDM::Base
      self.table_name = 'pdm_lu_prod_hiery'
      self.primary_key = 'eph_prod_node_id'
      attribute 'node_name', :xpdm_string

      with_options class_name: name do
        belongs_to :parent, primary_key: :eph_prod_node_id, inverse_of: :children
        has_many :children, primary_key: :parnt_node_id, inverse_of: :parent, dependent: :destroy
      end

      def top_level?
        parnt_node_id == 'EnterpriseProductHierarchy'
      end
    end
  end
end
