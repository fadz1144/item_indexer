module External
  module XPDM
    # = Dimensions Accessors
    #
    # The dimensions (both assembly and package) are stored by UOM. This module simplifies the access to those records,
    # making it as if the sku has one assembly length, for example.
    #
    # In the concept_sku_dimensions table, the fields are referred to as item (instead of assembly) and shipping
    # (instead of package).
    module DimensionsAccessors
      def item_length(uom = 'in')
        item_dimensions_for_uom(uom)&.asmbl_prod_lgth
      end

      def item_height(uom = 'in')
        item_dimensions_for_uom(uom)&.asmbl_prod_hght
      end

      def item_width(uom = 'in')
        item_dimensions_for_uom(uom)&.asmbl_prod_wdth
      end

      def item_diameter(uom = 'in')
        item_dimensions_for_uom(uom)&.asmbl_prod_diam
      end

      def item_dimension_shape(uom = 'in')
        shape(item_diameter(uom))
      end

      def item_weight(uom = 'lb')
        item_dimensions_for_uom(uom)&.asmbl_prod_wt
      end

      def shipping_length(uom = 'in')
        shipping_dimensions_for_uom(uom)&.case_lgth
      end

      def shipping_height(uom = 'in')
        shipping_dimensions_for_uom(uom)&.case_hght
      end

      def shipping_width(uom = 'in')
        shipping_dimensions_for_uom(uom)&.case_wdth
      end

      # not sure where the source of this is
      def shipping_diameter(_uom = 'in')
        nil
      end

      def shipping_dimension_shape(uom = 'in')
        shape(shipping_diameter(uom))
      end

      def shipping_weight(uom = 'lb')
        shipping_dimensions_for_uom(uom)&.case_wt
      end

      private

      def item_dimensions_for_uom(unit_of_measure)
        @item_dimensions_for_uom ||= {}
        @item_dimensions_for_uom.fetch(unit_of_measure) do |uom|
          @item_dimensions_for_uom[uom] = assembly_dimensions.find { |d| d.pdm_uom_cd == uom }
        end
      end

      def shipping_dimensions_for_uom(unit_of_measure)
        @shipping_dimensions_for_uom ||= {}
        @shipping_dimensions_for_uom.fetch(unit_of_measure) do |uom|
          @shipping_dimensions_for_uom[uom] = package_dimensions.find { |d| d.pdm_uom_cd == uom }
        end
      end

      def shape(diameter)
        diameter&.nonzero? ? 'CIRCULAR' : 'RECTANGULAR'
      end
    end
  end
end
