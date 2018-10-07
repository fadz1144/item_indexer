require 'rails_helper'

RSpec.describe External::XPDM::Image do
  let(:sku) do
    double('External::XPDM::Sku',
           image_relation: External::XPDM::ImageRelation.new(item_code_name_cd: 'IMG_123', item_code_name: 'oski.jpg'))
  end
  let(:image) { described_class.new(sku) }

  it '#resource_name' do
    expect(image.resource_name).to eq 'oski'
  end

  it '#alt_index' do
    expect(image.alt_index).to be_zero
  end

  it '#image_url' do
    expect(image.image_url).to eq 'https://s7d2.scene7.com/is/image/BedBathandBeyond/oski'
  end

  context 'with alt image' do
    let(:image) { described_class.new(sku, '1') }

    it '#resource_name' do
      expect(image.resource_name).to eq 'oski'
    end

    it '#alt_index' do
      expect(image.alt_index).to eq 1
    end

    it '#image_url' do
      expect(image.image_url).to eq 'https://s7d2.scene7.com/is/image/BedBathandBeyond/oski__1'
    end
  end
end
