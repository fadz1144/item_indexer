require 'rails_helper'

RSpec.describe External::ECOM::Inventory, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  it '.updates_since' do
    expect { described_class.updates_since(Time.zone.now).count }.not_to raise_exception
  end
end
