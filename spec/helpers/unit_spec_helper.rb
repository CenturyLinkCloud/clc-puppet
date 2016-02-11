RSpec.shared_examples "it has a non-empty string parameter" do |parameter|
  it "should be invalid without a #{parameter}" do
    create_params[parameter.to_sym] = nil
    expect { described_class.new(create_params) }.to raise_error(/#{parameter}/)
  end

  it "should be invalid with an empty #{parameter}" do
    create_params[parameter.to_sym] = '   '
    expect { described_class.new(create_params) }.to raise_error(/#{parameter}/)
  end
end
