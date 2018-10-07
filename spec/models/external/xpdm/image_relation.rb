require 'rails_helper'

RSpec.describe External::XPDM::ImageRelation do
  let(:image_relation) do
    described_class.new(item_code_name_cd: 'IMG_123', item_code_name: 'oski.jpg')
  end

  it '#image_asset_id' do
    expect(image_relation.image_asset_id).to eq 123
  end

  it '#image_name' do
    expect(image_relation.image_name).to eq 'oski'
  end
end
