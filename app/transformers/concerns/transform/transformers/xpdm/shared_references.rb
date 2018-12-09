module Transform
  module Transformers
    module XPDM
      module SharedReferences
        extend ActiveSupport::Concern

        included do
          references :vendor, association: :concept_vendor
          references :brand, association: :concept_brand
          references :eph_tree_node
          references :merch_dept_tree_node
          references :merch_sub_dept_tree_node
          references :merch_class_tree_node

          after_transform :handle_missing_brand
        end

        def handle_missing_brand(target)
          return if target.brand.present?

          target.brand = External::MissingBrandService.no_brand_assigned
          concept_brand = target.brand.concept_brands.first
          target.concept_children.each { |ci| ci.concept_brand = concept_brand }
        end
      end
    end
  end
end
