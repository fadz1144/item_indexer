require 'rails_helper'

RSpec.describe External::XPDM::Sku, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  it 'updates_since' do
    arel = described_class.updates_since(Time.zone.now)
    expect { arel.explain }.not_to raise_exception
  end

  it 'no_updates_since' do
    arel = described_class.no_updates_since(Time.zone.now)
    expect { arel.explain }.not_to raise_exception
  end
end
