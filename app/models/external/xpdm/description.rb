module External
  module XPDM
    # = Description
    #
    # The description table includes the concept flag (web_site_id) as well as flags for country and language. This
    # model is wrapped by the ConceptItemDescription and ConceptSkuDescription models to help choose the right record.
    class Description < External::XPDM::Base
      self.table_name = 'pdm_item_desc_detl'
      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :descriptions

      %i[mstr_shrt_desc mstr_prod_desc mstr_web_desc prod_desc web_prod_desc vdr_web_prod_desc jda_desc pos_desc]
        .each do |name|
        attribute name, :xpdm_string
      end

      alias_attribute :web_site_cd, :web_site_id # most places the field is called cd
    end
  end
end
