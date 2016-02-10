require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_server).provider(:v2) do
  let(:resource) {
    Puppet::Type.type(:clc_server).new(
      name: 'test',
      cpu: 1,
      memory: 1
    )
  }

  let(:provider) { resource.provider }

  it 'should be an instance of the ProviderV2' do
    expect(provider).to be_an_instance_of Puppet::Type::Clc_server::ProviderV2
  end

  describe 'create' do
    it 'is not implemented' do
      expect { provider.create }.to raise_error(NotImplementedError)
    end
  end

  describe 'destroy' do
    it 'is not implemented' do
      expect { provider.destroy }.to raise_error(NotImplementedError)
    end
  end
end
