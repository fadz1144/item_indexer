FactoryBot.define do
  factory :concept_sku_dimensions, class: 'CatModels::ConceptSkuDimensions' do
    sequence(:concept_sku_dimensions_id) { |n| 100 + n }
  end
end
