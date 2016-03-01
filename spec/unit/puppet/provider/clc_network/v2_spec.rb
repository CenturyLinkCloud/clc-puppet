require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_network).provider(:v2) do
  let(:resource) {
    Puppet::Type.type(:clc_network).new(
      name:       'test',
      datacenter: 'VA1',
    )
  }

  let(:provider) { resource.provider }

  it 'should be an instance of the ProviderV2' do
    expect(provider).to be_an_instance_of Puppet::Type::Clc_network::ProviderV2
  end

  describe 'create' do
    it 'should send a request to the CLC API to create the network' do
      VCR.use_cassette('create-network') do
        expect(provider.create).to be_truthy
      end
    end
  end
end
