require 'rails_helper'

RSpec.describe CatalogTransformer::Associations::SingularHandler do
  let(:handler) { described_class.new(source_team, target_team) }
  let(:transformer) { spy(CatalogTransformer::Base) }
  let(:transformer_class) { class_double(CatalogTransformer::Base, new: transformer) }

  let(:association) do
    instance_double(CatalogTransformer::Associations::SingularAssociation,
                    name: :coach,
                    source_name: :source_coach,
                    transformer_class: transformer_class)
  end

  let(:source_coach) { double 'SourceCoach' }
  let(:source_team) { double('SourceTeam', source_coach: source_coach) }

  context 'when target association does not exist' do
    let(:new_coach) { double 'NewCoach' }
    let(:target_team) { double('TargetTeam', coach: nil, build_coach: new_coach) }
    after { handler.transform_association(association) }

    it 'applies transformation to new instance' do
      expect(transformer).to receive(:apply_transformation).with(new_coach)
    end

    it 'uses team as source data for transformation' do
      expect(transformer_class).to receive(:new).with(source_coach)
    end
  end

  context 'when target association exists' do
    let(:existing_coach) { double 'ExistingCoach' }
    let(:target_team) { double('TargetTeam', coach: existing_coach) }
    after { handler.transform_association(association) }

    it 'applies transformation to existing instance' do
      expect(transformer).to receive(:apply_transformation).with(existing_coach)
    end

    it 'does not build new instance' do
      expect(target_team).not_to receive(:build_coach)
    end

    context 'when data for target association comes from main source and not a source association' do
      let(:association) do
        instance_double(CatalogTransformer::Associations::SingularAssociation,
                        name: :coach,
                        source_name: :itself,
                        transformer_class: transformer_class)
      end

      it 'uses team as source data for transformation' do
        expect(transformer_class).to receive(:new).with(source_team)
      end
    end
  end
end
