module Inbound
  module CommonConceptForeignKeys
    extend ActiveSupport::Concern

    included do
      belongs_to :concept,
                 optional: true,
                 class_name: 'CatModels::Concept',
                 foreign_key: :psuedo_concept_id

      belongs_to :concept_brand, -> { where(concept_id: 3) },
                 optional: true,
                 class_name: 'CatModels::ConceptBrand',
                 primary_key: :source_brand_id,
                 foreign_key: :brand_id

      belongs_to :concept_category, -> { where(concept_id: 3) },
                 optional: true,
                 class_name: 'CatModels::ConceptCategory',
                 primary_key: :source_category_id,
                 foreign_key: :category_id

      # TODO: update this once concept_vendors is updated to include concept_id and source_vendor_id
      belongs_to :concept_vendor,
                 optional: true,
                 class_name: 'CatModels::ConceptVendor',
                 primary_key: :concept_vendor_id,
                 foreign_key: :vendor_id
    end

    # allows models to support belongs_to :concept without carrying the foriegn key on the table
    def [](attr_name)
      if attr_name == :psuedo_concept_id
        3
      else
        super
      end
    end
  end
end
