module Transform
  module Transformers
    module XPDM
      class POSku < CatalogTransformer::Base
        source_name 'External::XPDM::POSku'
        attribute :sku_id, association: :sku, source_name: :pdm_object_id
        attribute :po_number, source_name: :ponumb
        attribute :cps_recid
        attribute :vendor_part_number, source_name: :part_num
        attribute :quantity, source_name: :pomqty
        attribute :pomorg, source_name: :pomorg
        attribute :po_type, source_name: :potype, association: :po_list
        attribute :store_number, source_name: :postor, association: :po_list
        attribute :created_date, source_name: :poedat2, association: :po_list
        attribute :close_date, source_name: :pocdat2, association: :po_list
        attribute :ship_date, source_name: :posdat2, association: :po_list
        attribute :cost, source_name: :poretl, association: :po_list
        attribute :units, source_name: :pounts, association: :po_list

        def self.source_includes
          [:po_list]
        end
      end
    end
  end
end
