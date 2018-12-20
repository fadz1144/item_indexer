require 'support/spec_promo_attribute_generator'
RSpec.shared_examples 'transformation includes promo attributes' do
  context 'with promo attributes' do
    let(:specified_dates) { [Date.new(2018, 8, 10), Date.new(2019, 8, 10)] }
    let(:name1) { '1_23 - Bogus Attr' }
    let(:name2) { '1_1867 - Canada is Awesome' }
    include SpecPromoAttributeGenerator
    before do
      build_promo_attribute(item: source, long_promo_cd: name1, concept_flags: 'YYY')
      allow(External::XPDM::PromoAttributeDefinition)
        .to receive(:cached_find).with(name1)
                                 .and_return(fake_promo_attrib_definition(name1, 'Bogus Attr'))

      build_promo_attribute(item: source, long_promo_cd: name2, concept_flags: 'NYN',
                            dates: specified_dates)
      allow(External::XPDM::PromoAttributeDefinition)
        .to receive(:cached_find).with(name2)
                                 .and_return(fake_promo_attrib_definition(name2, 'Canada Is Awesome'))

      transformer.apply_transformation(target)
    end

    describe 'promo attributes created' do
      let(:one_attribute) { target.promo_attributes.find { |a| a.promo_cd == '1_1867 - Canada is Awesome' } }
      it('quantity & kind') do
        expect(target.promo_attributes.map(&:class)).to eq [CatModels::PromoAttribute] * 2
      end
      it 'concept flags' do
        expect(target.promo_attributes.find { |a| a.promo_cd == '1_23 - Bogus Attr' }
                   .concept_flags.map { |f| '%s/%s' % [f.concept_id, f.applies] }.sort)
          .to eq %w[1/true 2/true 4/true]
        expect(one_attribute.concept_flags.map { |f| '%s/%s' % [f.concept_id, f.applies] }.sort)
          .to eq %w[1/false 2/true 4/false]
      end
      it('begin_date') { expect(one_attribute.begin_date).to eq specified_dates[0] }
      it('end_date') { expect(one_attribute.end_date).to eq specified_dates[1] }
      it('promo_cd') { expect(one_attribute.promo_cd).to eq name2 }
      it('internal_description') { expect(one_attribute.internal_description).to eq 'Canada Is Awesome' }
      it('site_description') do
        expect(one_attribute.site_description).to eq 'Canada Is Awesome Site Description'
      end
    end

    describe 'with wacky dates in source' do
      let(:wacky_start) { Date.new(1914, 7, 19) } # My grandfather was born
      let(:wacky_end) { Date.new(2161, 2, 28) } # United Federation of Planets formed
      let(:update_ts) { Time.zone.now - 2.years }
      before do
        allow(External::XPDM::PromoAttributeDefinition)
          .to receive(:cached_find).with('1_11 - wacky_dates')
                                   .and_return(fake_promo_attrib_definition('1_11 - wacky_dates', 'Wacky Dates'))
      end
      let(:this_attribute) { target.promo_attributes.find { |a| a.promo_cd == '1_11 - wacky_dates' } }
      describe 'wacky lower bound (it was set to more than 20 years before the update)' do
        before do
          build_promo_attribute(item: source, long_promo_cd: '1_11 - wacky_dates', concept_flags: 'NYN',
                                dates: [wacky_start, specified_dates[1]], update_ts: update_ts)
          transformer.apply_transformation(target)
        end
        it 'start is treated as the beginning of the year 20 years before the update instead' do
          earliest = Date.new(update_ts.year - 20, 1, 1)
          expect(this_attribute.begin_date).to be >= earliest
        end
      end
      describe 'wacky upper bound (more than 10 years after the record was updated)' do
        before do
          build_promo_attribute(item: source, long_promo_cd: '1_11 - wacky_dates', concept_flags: 'NYN',
                                dates: [specified_dates[0], wacky_end], update_ts: update_ts)
          transformer.apply_transformation(target)
        end
        it 'attribute is set to never end instead' do
          expect(this_attribute.end_date).to be_nil
        end
      end
    end
  end
end
