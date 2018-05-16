FactoryBot.define do
  factory :concept_product, class: 'CatModels::ConceptProduct' do
    sequence(:concept_product_id) { |n| 10_000 + n }
  end
end
