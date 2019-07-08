module External
  module XPDM
    class ConceptSku < External::XPDM::ConceptItem

      # has_one :image_relation, foreign_key: :pdm_object_id

      INVENTORY_PREFIXES = { 'BBBY' => 'bbb', 'CA' => 'ca', 'BABY' => 'bab' }.freeze

      alias_attribute :sku, :parent
      delegate :pdm_object_id,
               :item_length, :item_height, :item_width, :item_diameter, :item_weight, :item_dimension_shape,
               :shipping_length, :shipping_height, :shipping_width, :shipping_diameter, :shipping_weight,
               :shipping_dimension_shape, to: :sku
      delegate :jda_desc, :pos_desc, to: :@description, allow_nil: true
      attr_reader :afs_qty, :alt_afs_qty, :igr_qty, :inv_source

      def self.parent_associations
        %w[web_prices web_costs web_info_sites]
      end

      # this pushes the decision on whether or not to load inventory to the preload (full: yes, incremental: no)
      def self.from_parent(sku)
        super.tap do |concept_skus|
          concept_skus.each(&:load_inventory) if sku.association(:inventory).loaded?
        end
      end

      def concept_sku_images
        External::XPDM::Image.from_sku(sku)
      end

      def price
        @web_price&.web_reg_prc_amt
      end

      def cost
        @web_cost&.web_cst_amt
      end

      def force_below_the_line
        @web_info_site&.frc_blw_registry_ln_ind == 'Y'
      end

      # the inventory is only loaded during the full sku transformation, so these are all conditional to that
      def load_inventory
        prefix = INVENTORY_PREFIXES[web_site_cd]
        inventory = sku.inventory
        return if inventory.nil?

        @afs_qty = inventory.afs_qty
        @alt_afs_qty = inventory.public_send("#{prefix}_alt_afs_qty")
        @igr_qty = inventory.public_send("#{prefix}_igr_qty")
        @inv_source = inventory.inv_source
      end

      def warehouse_inventory?
        return nil unless sku.association(:inventory).loaded? && sku.inventory.present?
        sku.inventory.warehouse?
      end

      def vdc_inventory?
        return nil unless sku.association(:inventory).loaded? && sku.inventory.present?
        sku.inventory.vdc?
      end
    end
  end
end
