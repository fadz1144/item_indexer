module SOLR
  class BaseSerializer < ActiveModel::Serializer
    def self.stub_attributes(*attributes)
      attributes.each do |attribute|
        define_method(attribute) { nil }
      end
    end

    # these attributes don't exist for product or sku; if they are implemented in one but not the other, move this
    # declaration to the class without the attribute
    stub_attributes :available_in_ca, :clearance_status, :concept_eligibility, :contribution_margin_percent,
                    :dynamic_price_eligible, :inactive_reason, :inventory_ecom_us, :inventory_ecom_ca,
                    :inventory_okl_branded, :inventory_okl_vintage, :inventory_ropis, :inventory_total,
                    :inventory_store_total, :inventory_vdc_total, :jda_status, :line_of_business,
                    :personalized, :product_type, :size, :bbby_site_nav_tree_node_id,
                    :bbby_site_nav_tree_source_code, :bbby_site_nav_tree_node_name, :ca_site_nav_tree_node_id,
                    :ca_site_nav_tree_source_code, :ca_site_nav_tree_node_name, :baby_site_nav_tree_node_id,
                    :baby_site_nav_tree_source_code, :baby_site_nav_tree_node_name
  end
end
