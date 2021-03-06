module Transform
  module Transformers
    module OKL
      class Product < CatalogTransformer::Base
        include Transform::Transformers::OKL::ProductAndSkuSharedRollups

        source_name 'Inbound::OKL::ProductRevision'
        decorator_name 'Transform::Transformers::OKL::Decorators::ProductConceptProductDecorator'

        exclude :membership_hash, :eph_tree_node_id, :restock_notifiable, :vdc_min_days_to_ship,
                :vdc_max_days_to_ship, :web_copy_complete_status, :map_price, :rollup_type_name, :rollup_type_cd

        references :vendor, association: :concept_vendor
        references :brand, association: :concept_brand
        references :category, association: :concept_category
        references :merch_dept_tree_node
        references :merch_sub_dept_tree_node
        references :merch_class_tree_node

        private

        def other_concept_items
          @other_concept_items ||=
            CatModels::ConceptProduct.where(product_id: @source.product_id).where.not(concept_id: 3)
        end
      end
    end
  end
end
