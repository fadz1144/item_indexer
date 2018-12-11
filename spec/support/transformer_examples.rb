RSpec.shared_examples 'valid transformer' do
  it 'source_class is valid' do
    expect { described_class.source_class }.not_to raise_error
  end

  it 'target_class is valid' do
    expect { described_class.target_class }.not_to raise_error
  end

  it '#attribute_values does not raise error' do
    expect { transformer.attribute_values }.not_to raise_error
  end

  it '#apply_transformation does not raise error' do
    expect { transformer.apply_transformation(target) }.not_to raise_error
  end
end
