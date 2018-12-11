require 'rails_helper'

RSpec.describe SOLR::Decorators::SkuUniqDecoratedAttribute do
  let(:serializer) do
    Class.new do
      include SOLR::Decorators::SkuUniqDecoratedAttribute

      decorate_sku_uniq 'vendor_id', field: 'vendor_id'

      attr_reader :service

      def initialize(service)
        @service = service
      end
    end.new(instance_double(Serializers::DecoratedSkusSerializerService, decorated_skus_iterator_uniq: values))
  end

  context 'single vendor_id' do
    let(:values) { [500] }

    it('vendor_id') { expect(serializer.vendor_id).to eq [500] }
  end

  context 'multiple vendor_id' do
    let(:values) { [500, 501] }

    it('vendor_id') { expect(serializer.vendor_id).to eq [500, 501] }
  end
end
