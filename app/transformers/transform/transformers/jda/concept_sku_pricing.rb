module Transform
  module Transformers
    module JDA
      # I exist just to make sure you'll notice if you attempt to call this and expect to get back a symbol.
      class NoTargetKeyErrorObject; end
      class ConceptSkuPricing < CatalogTransformer::Base
        match_keys NoTargetKeyErrorObject.new, source_key: :compound_source_key
        source_name 'Inbound::JDA::PricingChange'
        attribute :retail_price, source_name: :AUREGU
        attribute :pre_markdown_price, source_name: :DPWASPRC
        # I think this (Coupon exclusion flag) would be useful in future
        # attribute :'????Coupon exclusion field name????', source_name: :coupon_exclusion
        attribute :map_price, source_name: :DPMAP
        attribute :source_updated_at, source_name: :DPCRTDT
        exclude :concept_sku_id, :concept_id, :source_sku_id, :cost,
                :margin_amount, :margin_percent, :source_created_by, :source_created_at, :source_updated_by

        def self.source_relation
          super.order(:DPCRTDT)
        end

        def self.load_indexed_targets(source_records)
          all_records = {}
          # Group source records by concept_id
          #   and for each concept they represent:
          source_records.group_by(&:concept_id).each do |concept_id, records|
            # Get all the target records and index them by the compound source key
            #          (see Inbound::JDA::PricingChange#compound_source_key for format)
            sku_ids = records.map(&:sku_id)
            this_concept_target_records = target_relation
                                          .where(concept_id: concept_id, sku_id: sku_ids)
                                          .to_a
                                          .index_by { |sku_pricing| compound_target_key(sku_pricing) }
            # Append them onto all_records
            all_records.merge!(this_concept_target_records)
          end
          all_records
        end

        def self.compound_target_key(object)
          '%d:%d' % [object.concept_id, object.sku_id]
        end

        module Decorations
          def coupon_exclusion
            read_attribute('DPCPNEX').to_s.casecmp('y').zero?
          end
        end
      end
    end
  end
end
