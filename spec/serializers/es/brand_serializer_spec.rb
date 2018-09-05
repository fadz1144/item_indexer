require 'rails_helper'

RSpec.describe ES::BrandSerializer do
  let(:brand_model) do
    CatModels::ConceptBrand.new(
      name: 'Some Brand',
      id: 99_999
    )
  end
  let(:serializer) { described_class.new(brand_model) }

  subject { JSON.parse(serializer.to_json) }

  it 'should have a name that matches' do
    expect(subject['name']).to eql(brand_model.name)
  end

  it 'should have an id that matches' do
    expect(subject['id']).to eql(brand_model.id)
  end
end
