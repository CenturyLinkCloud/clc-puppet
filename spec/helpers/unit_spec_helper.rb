RSpec.shared_examples "it has a validated name" do
  it "should be invalid without a name" do
    create_params[:name] = nil
    expect { described_class.new(create_params) }.to raise_error(/name/)
  end

  it "should be invalid with an empty name" do
    create_params[:name] = '   '
    expect { described_class.new(create_params) }.to raise_error(/name/)
  end
end
