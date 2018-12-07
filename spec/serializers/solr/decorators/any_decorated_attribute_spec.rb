require 'rails_helper'

RSpec.describe SOLR::Decorators::AnyDecoratedAttribute do
  let(:serializer) do
    Class.new do
      include SOLR::Decorators::AnyDecoratedAttribute

      decorate_any 'live', field: 'live'
      attr_reader :service

      def initialize(service)
        @service = service
      end
    end.new(instance_double(Serializers::DecoratedSkusSerializerService, concept_skus_any?: value))
  end

  context 'true' do
    let(:value) { true }
    it { expect(serializer.live).to be true }
  end

  context 'false' do
    let(:value) { false }
    it { expect(serializer.live).to be false }
  end
end
