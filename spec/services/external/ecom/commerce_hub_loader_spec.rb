require 'rails_helper'

RSpec.describe External::ECOM::CommerceHubLoader do
  let(:loader) { described_class.new }
  describe '#look_back_window' do
    it('responds to') { expect(loader).to respond_to(:look_back_window) }
    it('defaults to three days') { expect(loader.look_back_window).to eq 3.days }

    it 'allows override' do
      loader = described_class.new(10.days)
      expect(loader.look_back_window).to eq 10.days
    end
  end
end
