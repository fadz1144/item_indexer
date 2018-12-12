require 'rails_helper'

RSpec.describe External::DirectLoadService, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:loader) { External::XPDM::ProductLoader.new }
  let(:service) { described_class.new(loader) }
  let(:engine) { instance_double(CatalogTransformer::Engine) }

  before do
    allow(External::BatchLoader).to receive(:execute_in_batch).and_yield(engine)
  end

  context '#full' do
    context 'with no restart' do
      it 'instantiates direct batch' do
        expect(Direct::Batch).to receive(:new).with(class_name: loader.class.name, criteria_type: :full, criteria: nil)
                                              .and_return(instance_spy(Direct::Batch))
        service.full
      end

      it 'records count' do
        db = instance_spy(Direct::Batch)
        allow(Direct::Batch).to receive(:new).and_return(db)
        service.full
        expect(db).to have_received(:count=).with(0)
      end

      it 'calls transform on loader' do
        expect(loader).to receive(:transform).with(engine, ActiveRecord::Relation)
        service.full
      end
    end

    context 'with restart' do
      RSpec::Matchers.define :arel_with_greater_than_clause do |id|
        match do |arel|
          md = arel.to_sql.match(/"PDM_OBJECT_ID" > (\d+)/)
          md.present? && md.captures.first == id.to_s
        end
      end

      before { allow(loader).to receive(:restart_id).and_return(456) }

      it 'adds last Id to arel' do
        expect(loader).to receive(:transform).with(engine, arel_with_greater_than_clause(456))
        service.full
      end
    end
  end

  context '#partial' do
    it 'instantiates direct batch' do
      expect(Direct::Batch).to receive(:new)
        .with(class_name: loader.class.name, criteria_type: :partial, criteria: include('go bears!'))
        .and_return(instance_spy(Direct::Batch))
      service.partial(loader.base_arel.where("'oski says' = 'go bears!'"))
    end

    RSpec::Matchers.define :arel_with_criteria do |criteria|
      match { |arel| arel.is_a?(ActiveRecord::Relation) && arel.to_sql.match?(criteria) }
    end

    it 'uses criteria' do
      arel = External::XPDM::Product.where('1 = 2')
      expect(loader).to receive(:transform).with(engine, arel_with_criteria('1 = 2'))
      service.partial(arel)
    end
  end

  context '#individual' do
    after { service.individual([123, 234]) }

    it 'instantiates direct batch' do
      expect(Direct::Batch).to receive(:new)
        .with(class_name: loader.class.name, criteria_type: :individual, criteria: [123, 234])
        .and_return(instance_spy(Direct::Batch))
    end

    RSpec::Matchers.define :arel_with_pdm_object_ids do |ids|
      match { |arel| arel.is_a?(ActiveRecord::Relation) && arel.where_values_hash['pdm_object_id'] == ids }
    end

    it 'uses criteria' do
      expect(loader).to receive(:transform).with(engine, arel_with_pdm_object_ids([123, 234]))
    end
  end

  context '#incremental' do
    let(:timestamp) { Time.zone.now - 2.weeks }

    it 'instantiates direct batch' do
      expect(Direct::Batch).to receive(:new)
        .with(class_name: loader.class.name, criteria_type: :incremental, criteria: timestamp)
        .and_return(instance_spy(Direct::Batch))
      service.incremental(timestamp)
    end

    RSpec::Matchers.define :arel_with_updates_since do
      match { |arel| arel.to_sql.match?(/coalesce\("\w+".update_ts, "\w+".create_ts\) >= TO_DATE/) }
    end

    it 'restricts by timestamp' do
      expect(loader).to receive(:transform).with(engine, arel_with_updates_since)
      service.incremental(timestamp)
    end
  end
end
