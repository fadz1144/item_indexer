module Transform
  module Transformers
    module XPDM
      # = Parent Tag
      #
      # Transformer ParentTag is used to load tags directly to the parent. It is meant for a one-time, initial load. It
      # does not check for existing tags. The loader should call the engine's transform_item with a new instance of Tag
      # that has been instantiated with the taggable parent.
      #
      # The tag parent can be a collection, product, or sku.
      class ParentTag < CatalogTransformer::Base
        def attribute_values
          source.created_updated_stamp_attributes.merge(tag_value: source.cm_tag_free_frm_txt)
        end
      end
    end
  end
end
