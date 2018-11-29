module Transform
  module Transformers
    module XPDM
      class Tag < CatalogTransformer::Base
        source_name 'External::XPDM::CMTag'
        exclude :taggable_type, :taggable_id

        module Decorations
          # requires decorator instead of attribute mapping because it is also the match key
          def tag_value
            cm_tag_free_frm_txt
          end
        end
      end
    end
  end
end
