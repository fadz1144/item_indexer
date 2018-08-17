module Transform
  module Transformers
    module OKL
      class Product < CatalogTransformer::Base
        source_name 'Inbound::OKL::ProductRevision'
        decorator_name 'Transform::Transformers::OKL::Decorators::ProductConceptProductDecorator'

        exclude :membership_hash, :eph_tree_node_id, :merch_dept_tree_node_id, :merch_sub_dept_tree_node_id,
                :merch_class_tree_node_id

        references :vendor, association: :concept_vendor
        references :brand, association: :concept_brand
        references :category, association: :concept_category
      end
    end
  end
end
