module Inbound
  module OKL
    class CategoryRevision < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'

      belongs_to :parent_concept_category, -> { where(concept_id: 3) },
                 optional: true,
                 class_name: 'CatModels::ConceptCategory',
                 primary_key: :source_category_id,
                 foreign_key: :parent_id
    end
  end
end
