require 'rails_helper'

RSpec.describe CatalogTransformer::Callbacks do
  let(:transformer) do
    Class.new do
      include CatalogTransformer::Callbacks

      before_transform :one
      before_transform :two

      after_transform { |target| target << 'go' }
      after_transform do |target|
        target << 'bears'
      end

      attr_accessor :results

      def one(target)
        results << target + 1
      end

      def two(target)
        results << target + 2
      end
    end.new
  end

  it 'runs before callbacks' do
    target = 42
    transformer.results = []
    transformer.run_callbacks(:before, target)
    expect(transformer.results).to contain_exactly(43, 44)
  end

  it 'runs after callbacks (with blocks!)' do
    target = []
    transformer.run_callbacks(:after, target)
    expect(target).to contain_exactly('go', 'bears')
  end
end
