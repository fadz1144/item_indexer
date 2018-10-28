FactoryBot.define do
  factory :concept_sku, class: 'CatModels::ConceptSku' do
    sequence(:concept_sku_id) { |n| 100 + n }

    trait :live do
      live { true }
    end

    trait :with_dimensions do
      association :concept_sku_dimensions, factory: :concept_sku_dimensions, strategy: :build
    end

    factory :full_concept_sku, traits: %i[with_dimensions]
  end
end
