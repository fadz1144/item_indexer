FactoryBot.define do
  factory :sku, class: 'CatModels::Sku' do
    sequence(:sku_id) { |n| 1000 + n }
  end
end
