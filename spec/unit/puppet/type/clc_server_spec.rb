require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_server) do
  let(:create_params) {
    {
      :name             => 'name',
      :group_id         => 'group-id',
      :source_server_id => 'server-id',
      :cpu              => 1,
      :memory           => 1,
    }
  }

  [:name, :group_id, :source_server_id].each do |field|
    it_behaves_like "it has a non-empty string parameter", field
  end

  describe 'cpu' do
    it 'does not allow negatives' do
      create_params[:cpu] = -1
      expect { described_class.new(create_params) }.to raise_error(/cpu/)
    end

    it 'does not allow 0' do
      create_params[:cpu] = 0
      expect { described_class.new(create_params) }.to raise_error(/cpu/)
    end

    it 'does not allow > 16' do
      create_params[:cpu] = 17
      expect { described_class.new(create_params) }.to raise_error(/cpu/)
    end
  end

  describe 'memory' do
    it 'does not allow negatives' do
      create_params[:memory] = -1
      expect { described_class.new(create_params) }.to raise_error(/memory/)
    end

    it 'does not allow 0' do
      create_params[:memory] = 0
      expect { described_class.new(create_params) }.to raise_error(/memory/)
    end

    it 'does not allow > 128' do
      create_params[:memory] = 129
      expect { described_class.new(create_params) }.to raise_error(/memory/)
    end
  end

  describe 'managed' do
    it 'sets to false by default' do
      expect(described_class.new(create_params)[:managed]).to be false
    end
  end

  describe 'managed_backup' do
    it 'sets to false by default' do
      expect(described_class.new(create_params)[:managed_backup]).to be false
    end
    it 'does not allow to set to true when "managed" is false' do
      create_params[:managed] = false
      create_params[:managed_backup] = true
      expect { described_class.new(create_params) }.to raise_error(/managed_backup/)
    end
  end

  describe 'type' do
    [:standard, :hyperscale, :bareMetal].each do |type|
      it "allows #{type}" do
        create_params[:type] = type
        expect { described_class.new(create_params) }.to_not raise_error
      end
    end

    specify do
      create_params[:type] = 'invalid'
      expect { described_class.new(create_params) }.to raise_error(/type/)
    end

    it 'sets "standard" by default' do
      expect(described_class.new(create_params)[:type]).to eq :standard
    end
  end

  describe 'ip_address' do
    it 'validates value must be a valid IP' do
      create_params[:ip_address] = 'invalid'
      expect { described_class.new(create_params) }.to raise_error(/ip_address/)
    end
  end
end
