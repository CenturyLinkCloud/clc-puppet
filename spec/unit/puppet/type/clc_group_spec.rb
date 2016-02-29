require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_group) do
  let(:create_params) {
    {
      :name            => 'name',
      :parent_group_id => 'parent-group',
    }
  }

  [:name, :parent_group_id, :parent_group, :datacenter].each do |field|
    it_behaves_like "it has a non-empty string parameter", field
  end

  it_behaves_like "it has a read-only parameter", :id

  it_behaves_like "it has custom fields"

  describe 'defaults' do
    before { create_params[:defaults] = {} }

    describe 'cpu' do
      it 'does not allow negatives' do
        create_params[:defaults][:cpu] = -1
        expect { described_class.new(create_params) }.to raise_error(/default cpu/)
      end

      it 'does not allow 0' do
        create_params[:defaults][:cpu] = 0
        expect { described_class.new(create_params) }.to raise_error(/default cpu/)
      end

      it 'does not allow > 16' do
        create_params[:defaults][:cpu] = 17
        expect { described_class.new(create_params) }.to raise_error(/default cpu/)
      end
    end

    describe 'memory' do
      it 'does not allow negatives' do
        create_params[:defaults][:memory] = -1
        expect { described_class.new(create_params) }.to raise_error(/default memory/)
      end

      it 'does not allow 0' do
        create_params[:defaults][:memory] = 0
        expect { described_class.new(create_params) }.to raise_error(/default memory/)
      end

      it 'does not allow > 128' do
        create_params[:defaults][:memory] = 129
        expect { described_class.new(create_params) }.to raise_error(/default memory/)
      end
    end

    [:network_id, :primary_dns, :secondary_dns, :template_name].each do |field|
      describe field.to_s do
        it "should be invalid given non-string" do
          create_params[:defaults][field] = 1
          expect { described_class.new(create_params) }.to raise_error(/default #{field}/)
        end
      end
    end
  end
end
