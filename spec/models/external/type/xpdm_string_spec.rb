require 'rails_helper'

RSpec.describe External::Type::XPDMString, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:type) { described_class.new }

  it 'handles registered trademark character 174' do
    expect(type.deserialize("Oski\xAE")).to eq 'Oski®'
  end

  it 'handles registered trademark html &reg;' do
    expect(type.deserialize('Oski&reg;')).to eq 'Oski®'
  end

  it 'handles e with a hat' do
    expect(type.deserialize("Home D\xE9cor")).to eq 'Home Décor'
  end
end
