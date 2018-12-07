require 'rails_helper'

RSpec.describe SOLR::Decorators::FieldUniqDecoratedAttribute do
  let(:serializer) do
    Class.new do
      include SOLR::Decorators::FieldUniqDecoratedAttribute

      decorate_field_uniq 'min_lead_time', field: 'lead_time', group: 'min'
      decorate_field_uniq 'max_lead_time', field: 'lead_time', group: 'max'

      attr_reader :service

      def initialize(service)
        @service = service
      end
    end.new(instance_double(Serializers::DecoratedSkusSerializerService, field_unique_values: values))
  end

  context 'single unique lead time' do
    let(:values) { [5] }

    it('min_lead_time') { expect(serializer.min_lead_time).to eq 5 }
    it('max_lead_time') { expect(serializer.max_lead_time).to eq 5 }
  end

  context 'multiple unique lead times' do
    let(:values) { [3, 4, 5] }

    it('min_lead_time') { expect(serializer.min_lead_time).to eq 3 }
    it('max_lead_time') { expect(serializer.max_lead_time).to eq 5 }
  end
end
