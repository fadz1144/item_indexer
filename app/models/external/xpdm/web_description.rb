module External
  module XPDM
    class WebDescription < External::XPDM::Base
      self.table_name = 'pdm_item_desc_web'
      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :descriptions

      %i[web_prc_str_desc]
        .each do |name|
        attribute name, :xpdm_string
      end

      alias_attribute :web_site_id, :web_site_cd # most places the field is called cd

      def concept_id
        case web_site_cd
        when 'BBBY' then
          1
        when 'CA' then
          2
        when 'BABY' then
          4
        else
          raise "Invalid web_site_cd: #{web_site_cd}"
        end
      end
    end
  end
end
