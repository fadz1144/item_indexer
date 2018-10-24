require 'rails_helper'

RSpec.describe CatalogTransformer::Callbacks do
  let(:transformer) do
    Class.new do
      include CatalogTransformer::Callbacks

      before_transform :one
      before_transform :two

      after_transform { |target| target.things_oski_says << 'go' }
      after_transform do |target|
        target.things_oski_says << 'bears'
      end

      attr_accessor :results

      def one(target)
        target.more_numbers << target.number + 1
      end

      def two(target)
        target.more_numbers << target.number + 2
      end

      before_save { |target| target.number = target.number + 1 }
      after_save { |target| target.number = target.number + 1 }
    end.new
  end

  let(:target) { OpenStruct.new(number: 42, more_numbers: [], things_oski_says: []) }

  it 'runs before transform callbacks' do
    transformer.with_callbacks(:transform, target) { nil }
    expect(target.more_numbers).to contain_exactly(43, 44)
  end

  it 'runs after transform callbacks (with blocks!)' do
    transformer.with_callbacks(:transform, target) { nil }
    expect(target.things_oski_says).to contain_exactly('go', 'bears')
  end

  it 'runs save callbacks' do
    transformer.with_callbacks(:save, target) { nil }
    expect(target.number).to eq 44
  end

  it 'invokes block' do
    forty_three = 0
    transformer.with_callbacks(:save, target) { forty_three = target.number }
    expect(forty_three).to eq 43
  end
end
