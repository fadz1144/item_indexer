module Transform
  module Transformers
    module ECOM
      class CommerceHub < CatalogTransformer::Base
        source_name 'External::ECOM::CommerceHub'
        target_name 'CatModels::Sku'
        match_keys :upc
        specified_attributes_only
        suppress_record_creation

        # number in CatModels, string in ECOM; override to index by string
        def self.load_indexed_targets(source_records)
          target_relation.where(gtin: source_records.map(&:upc)).index_by { |s| s.gtin.to_s }
        end

        # the sku save validates these, so eager load them
        def self.target_includes
          %i[brand vendor]
        end

        attribute :vendor_discontinued_at, source_name: :discontinued_dt
        attribute :vendor_available_qty, source_name: :curr_qty
        attribute :vendor_availability_status
        attribute :vendor_next_available_qty, source_name: :next_avail_qty
        attribute :vendor_next_available_at, source_name: :next_avail_dt
        attribute :vendor_inventory_last_updated_at, source_name: :comhub_mod_dt

        module Decorations
          def vendor_availability_status
            availability_status&.titleize
          end
        end
      end
    end
  end
end
