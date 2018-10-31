require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::Sku do
  let(:source) { Inbound::OKL::SkuRevision.new.tap(&:build_state) }
  let(:target) { CatModels::Sku.new }

  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it 'maps upc to gtin' do
      source.upc = 123
      expect(values['gtin']).to eq 123
    end

    context '#image_count' do
      let(:image_count) { values['image_count'] }

      it 'returns zero with no images' do
        expect(image_count).to eq 0
      end

      it 'returns two with two images' do
        source.images.build
        source.images.build
        expect(image_count).to eq 2
      end
    end
  end

  context 'web_flags_summary' do
    it 'populates when no existing value' do
      allow(transformer.source).to receive(:web_flags_summary).and_return('oski')
      transformer.apply_transformation(target)
      expect(target.web_flags_summary).to eq 'oski'
    end

    it 'updates when source is Live on Site' do
      allow(transformer.source).to receive(:web_flags_summary)
        .and_return(CatModels::Constants::WebFlagsSummary::LIVE_ON_SITE)
      target.web_flags_summary = 'oski'
      transformer.apply_transformation(target)
      expect(target.web_flags_summary).to eq CatModels::Constants::WebFlagsSummary::LIVE_ON_SITE
    end

    it 'updates when no other concept skus' do
      transformer.instance_variable_set(:@other_concept_items, [])
      allow(transformer.source).to receive(:web_flags_summary)
        .and_return(CatModels::Constants::WebFlagsSummary::SUSPENDED)
      target.web_flags_summary = CatModels::Constants::WebFlagsSummary::LIVE_ON_SITE
      transformer.apply_transformation(target)
      expect(target.web_flags_summary).to eq CatModels::Constants::WebFlagsSummary::SUSPENDED
    end

    it 'uses rollup when existing value and not Live on Site and other skus' do
      target.web_flags_summary = CatModels::Constants::WebFlagsSummary::LIVE_ON_SITE
      allow(transformer.source).to receive(:web_flags_summary)
        .and_return(CatModels::Constants::WebFlagsSummary::SUSPENDED)
      other = CatModels::ConceptSku.new(web_flags_summary: CatModels::Constants::WebFlagsSummary::IN_WORKFLOW)
      transformer.instance_variable_set(:@other_concept_items, [other])
      transformer.apply_transformation(target)
      expect(target.web_flags_summary).to eq CatModels::Constants::WebFlagsSummary::IN_WORKFLOW
    end
  end

  context 'web_status' do
    it 'populates when no existing value' do
      allow(transformer.source).to receive(:web_status).and_return('oski')
      transformer.apply_transformation(target)
      expect(target.web_status).to eq 'oski'
    end

    it 'updates when source is Active' do
      allow(transformer.source).to receive(:web_status)
        .and_return(CatModels::Constants::SystemStatus::ACTIVE)
      target.web_status = 'oski'
      transformer.apply_transformation(target)
      expect(target.web_status).to eq CatModels::Constants::SystemStatus::ACTIVE
    end

    it 'updates when no other concept skus' do
      transformer.instance_variable_set(:@other_concept_items, [])
      allow(transformer.source).to receive(:web_status)
        .and_return(CatModels::Constants::SystemStatus::DROPPED)
      target.web_status = CatModels::Constants::SystemStatus::ACTIVE
      transformer.apply_transformation(target)
      expect(target.web_status).to eq CatModels::Constants::SystemStatus::DROPPED
    end

    it 'uses rollup when existing value and not Live on Site and other skus' do
      target.web_status = CatModels::Constants::SystemStatus::ACTIVE
      allow(transformer.source).to receive(:web_status)
        .and_return(CatModels::Constants::SystemStatus::DROPPED)
      other = CatModels::ConceptSku.new(web_status: CatModels::Constants::SystemStatus::INACTIVE)
      transformer.instance_variable_set(:@other_concept_items, [other])
      transformer.apply_transformation(target)
      expect(target.web_status).to eq CatModels::Constants::SystemStatus::INACTIVE
    end
  end
end
