module Transform
  module Transformers
    module XPDM
      class ConceptBrand < CatalogTransformer::Base
        cattr_accessor :concept, :brand_cache
        source_name 'External::XPDM::Brand'
        match_keys :source_brand_id, source_key: :brand_cd
        attribute :name, source_name: :brand_name
        references :brand
        references :concept
        exclude :description

        def self.target_relation
          super.where(concept_id: 99)
        end

        def self.init_class_variables
          self.concept = CatModels::Concept.find(99)
          # reversing the order so the first Id is used when a name appears more than once
          self.brand_cache = CatModels::Brand.order(brand_id: :desc).index_by(&:name)
        end

        def self.load_indexed_targets(source_records)
          super.transform_keys(&:to_s)
        end

        module Decorations
          def concept
            Transform::Transformers::XPDM::ConceptBrand.concept
          end

          def brand
            Transform::Transformers::XPDM::ConceptBrand.brand_cache[brand_name] ||
              CatModels::Brand.new(name: brand_name)
          end

          def source_brand_id
            brand_cd.to_i
          end

          def active
            true
          end

          def status
            'ACTIVE'
          end
        end
      end
    end
  end
end
