module External
  module XPDM
    class ConceptProduct < External::XPDM::ConceptItem
      def self.parent_associations
        %w[web_info_sites]
      end

      alias_attribute :product, :parent

      def pdp_url
        "#{WEB_SITES[web_site_cd]}/store/product/#{mstr_prod_desc&.parameterize || 'pc'}/#{product.pdm_object_id.to_i}"
      end
    end
  end
end
