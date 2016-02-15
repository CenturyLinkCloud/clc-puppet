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

RSpec.shared_examples "it has a read-only parameter" do |parameter|
  it "should fail when trying to set #{parameter}" do
    create_params[parameter.to_sym] = 'somevalue'
    expect { described_class.new(create_params) }.to raise_error(/read-only/)
  end
end

RSpec.shared_examples "it has custom fields" do |parameter|
  it "should be valid when custom_fields is an empty array" do
    create_params[:custom_fields] = []
    expect { described_class.new(create_params) }.to_not raise_error
  end

  it "should be invalid when custom field isnt a hash" do
    create_params[:custom_fields] = ['invalid']
    expect { described_class.new(create_params) }.to raise_error(/custom field/)
  end

  it "should be invalid when custom field doesnt have 'id'" do
    create_params[:custom_fields] = [{value: 'some-value'}]
    expect { described_class.new(create_params) }.to raise_error(/custom field/)
  end

  it "should be invalid when custom field doesnt have 'value'" do
    create_params[:custom_fields] = [{id: 'some-id'}]
    expect { described_class.new(create_params) }.to raise_error(/custom field/)
  end
end
