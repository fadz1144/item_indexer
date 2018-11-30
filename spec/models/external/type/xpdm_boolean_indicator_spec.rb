require 'rails_helper'

RSpec.describe External::Type::XPDMBooleanIndicator, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:type) { described_class.new }

  context 'true values' do
    %w[Y Yes y yes].each do |value|
      it(value.to_s) { expect(type.deserialize(value)).to be true }
    end
  end

  context 'false values' do
    %w[No N U no Oski].each do |value|
      it(value.to_s) { expect(type.deserialize(value)).to be false }
    end

    it('nil') { expect(type.deserialize(nil)).to be false }
  end
end
