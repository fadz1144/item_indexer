module Transform
  module Transformers
    module XPDM
      module SharedConceptReferences
        extend ActiveSupport::Concern

        included do
          references :concept
          references :concept_vendor
          references :concept_brand
          references :site_nav_tree_node
        end
      end
    end
  end
end
