module External
  module XPDM
    # requires the following attributes: web_site_cd, mstr_prod_desc, and parent
    module PDPUrl
      WEB_SITES = { 'BBBY' => 'www.bedbathandbeyond.com',
                    'CA' => 'www.bedbathandbeyond.ca',
                    'BABY' => 'www.buybuybaby.com' }.freeze

      def pdp_url
        "#{WEB_SITES[web_site_cd]}/store/product/#{mstr_prod_desc&.parameterize || 'pc'}/#{parent.pdm_object_id.to_i}"
      end
    end
  end
end
