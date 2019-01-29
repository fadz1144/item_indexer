module External
  module XPDM
    class TruckShippingMethod < External::XPDM::Base
      self.table_name = :pdm_item_lgstcs_ltl_mth
      INCLUDED_COLUMNS = %w[pdm_object_id ltl_elg_shp_meth_name].freeze
      default_scope -> { select(INCLUDED_COLUMNS) }
      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :shipping_methods

      THRESHOLD = 'Threshold'.freeze
      ROOM_OF_CHOICE = 'Room Of Choice'.freeze
      WHITE_GLOVE = 'White Glove'.freeze
      SORT_ORDER = [THRESHOLD, 'Room of Choice', WHITE_GLOVE].freeze

      # given an array of records, return a uniq, sorted list of valid shipping methods
      def self.shipping_methods(shipping_methods)
        shipping_methods.flat_map(&:shipping_method)
                        .compact.uniq
                        .sort_by { |sm| SORT_ORDER.index(sm) || 99 }
                        .join(', ')
      end

      # each valid value has a bizarro value that ends with "Special", this just collapses those back to valid values
      def shipping_method
        @shipping_method ||=
          if ltl_elg_shp_meth_name.nil? then nil
          elsif ltl_elg_shp_meth_name.include?(THRESHOLD) then THRESHOLD
          elsif ltl_elg_shp_meth_name.include?(ROOM_OF_CHOICE) then 'Room of Choice'
          elsif ltl_elg_shp_meth_name.include?(WHITE_GLOVE) then WHITE_GLOVE
          end
      end
    end
  end
end
