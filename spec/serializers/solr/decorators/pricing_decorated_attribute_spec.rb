require 'rails_helper'

RSpec.describe SOLR::Decorators::PricingDecoratedAttribute do
  let(:serializer) do
    Class.new do
      include SOLR::Decorators::PricingDecoratedAttribute

      decorate_pricing 'min_cost', field: 'cost', group: 'min'
      decorate_pricing 'max_cost', field: 'cost', group: 'max'

      attr_reader :service

      def initialize(service)
        @service = service
      end
    end.new(instance_double(Serializers::DecoratedSkusSerializerService, sku_pricing_field_values: values))
  end

  context 'single value cost' do
    let(:values) { [5.00] }

    it('min_cost') { expect(serializer.min_cost).to eq 5.00 }
    it('max_cost') { expect(serializer.max_cost).to eq 5.00 }
  end

  context 'false' do
    let(:values) { [3.00, 4.00, 5.00] }

    it('min_cost') { expect(serializer.min_cost).to eq 3.00 }
    it('max_cost') { expect(serializer.max_cost).to eq 5.00 }
  end
end
