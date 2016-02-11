require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_server).provider(:v2) do
  let(:resource) {
    Puppet::Type.type(:clc_server).new(
      name:             'test',
      group_id:         '5757349d19c343a88ce9a473fe2522f4',
      source_server_id: 'DEBIAN-7-64-TEMPLATE',
      cpu:              1,
      memory:           1,
    )
  }

  let(:provider) { resource.provider }

  before(:all) do
    ENV['CLC_USERNAME'] = 'redacted'
    ENV['CLC_PASSWORD'] = 'redacted'
  end

  it 'should be an instance of the ProviderV2' do
    expect(provider).to be_an_instance_of Puppet::Type::Clc_server::ProviderV2
  end

  describe 'create' do
    it 'should send a request to the CLC API to create the server' do
      VCR.use_cassette('create-server') do
        expect(provider.create).to be_truthy
      end
    end
  end

  describe 'destroy' do
    it 'is not implemented' do
      expect { provider.destroy }.to raise_error(NotImplementedError)
    end
  end
end
