require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_group).provider(:v2) do
  let(:resource) {
    Puppet::Type.type(:clc_group).new(
      name:             'test',
      description:      'test group',
      parent_group_id:  '5757349d19c343a88ce9a473fe2522f4',
    )
  }

  let(:provider) { resource.provider }

  it 'should be an instance of the ProviderV2' do
    expect(provider).to be_an_instance_of Puppet::Type::Clc_group::ProviderV2
  end

  describe 'create' do
    it 'should send a request to the CLC API to create the group' do
      VCR.use_cassette('create-group') do
        expect(provider.create).to be_truthy
      end
    end
  end

  describe 'destroy' do
    it 'should send a request to the CLC API to destroy the group' do
      VCR.use_cassette('destroy-group') do
        expect(provider.destroy).to be_truthy
      end
    end
  end
end
