require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_template).provider(:v2) do
  let(:resource) {
    Puppet::Type.type(:clc_template).new(name: 'test')
  }

  let(:provider) { resource.provider }

  it 'should be an instance of the ProviderV2' do
    expect(provider).to be_an_instance_of Puppet::Type::Clc_template::ProviderV2
  end
end
