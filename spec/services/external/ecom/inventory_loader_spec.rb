require 'rails_helper'

RSpec.describe External::ECOM::InventoryLoader do
  it 'has valid arel for target skus' do
    arel = described_class.new.send(:target_skus_arel, [1, 2, 3])
    expect { arel.explain }.not_to raise_exception
  end
end
