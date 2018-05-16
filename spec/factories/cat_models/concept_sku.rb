FactoryBot.define do
  factory :concept_sku, class: 'CatModels::ConceptSku' do
    sequence(:concept_sku_id) { |n| 100 + n }

    trait :live do
      live true
    end
  end
end
