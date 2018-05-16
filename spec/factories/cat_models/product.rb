FactoryBot.define do
  factory :product, class: 'CatModels::Product' do
    sequence(:product_id) { |n| 1000 + n }
  end
end
