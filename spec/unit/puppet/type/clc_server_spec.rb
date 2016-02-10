require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_server) do
  let(:create_params) {
    {
      :name   => 'name',
      :cpu    => 1,
      :memory => 1,
    }
  }

  it_behaves_like "it has a validated name"

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
end
