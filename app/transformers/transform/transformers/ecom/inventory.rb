module Transform
  module Transformers
    module ECOM
      class Inventory < CatalogTransformer::Base
        def apply_transformation(target)
          target.assign_attributes(qty_attribute_values(target.concept_id))
        end

        def qty_attribute_values(concept_id)
          qty = @source.afs_qty + @source.concept_quantity(concept_id)

          { 'total_avail_qty' => qty,
            'warehouse_avail_qty' => @source.warehouse? ? qty : 0,
            'vdc_avail_qty' => @source.vdc? ? qty : 0 }
        end

        module Decorations
          def concept_quantity(concept_id)
            case concept_id
            when 1
              bbb_alt_afs_qty
            when 2
              ca_alt_afs_qty
            when 4
              bab_alt_afs_qty
            else
              raise "Unknown concept_id (#{concept_id}) for ECOM Inventory"
            end
          end
        end
      end
    end
  end
end
