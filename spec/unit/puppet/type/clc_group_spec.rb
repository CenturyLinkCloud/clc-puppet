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

  describe 'scheduled_activities' do
    before do
      create_params[:scheduled_activities] = {
        status: 'on',
        type: 'reboot',
        begin_date: '2016-03-02T10:59:45Z',
        repeat: 'daily',
        expire: 'never',
      }
    end

    [:status, :type, :begin_date, :repeat, :expire].each do |field|
      describe field.to_s do
        it 'does not allow nil value' do
          create_params[:scheduled_activities][field] = nil
          expect { described_class.new(create_params) }.to raise_error(/scheduled_activities #{field}/)
        end
      end
    end

    describe 'status' do
      ['on', 'off'].each do |value|
        it "accepts '#{value}' value" do
          create_params[:scheduled_activities][:status] = value
          expect { described_class.new(create_params) }.to_not raise_error
        end
      end
      specify do
        create_params[:scheduled_activities][:status] = 'invalid'
        expect { described_class.new(create_params) }.to raise_error(/scheduled_activities status/)
      end
    end

    describe 'type' do
      %w[archive createsnapshot delete deletesnapshot pause poweron reboot shutdown].each do |value|
        it "accepts '#{value}' value" do
          create_params[:scheduled_activities][:type] = value
          expect { described_class.new(create_params) }.to_not raise_error
        end
      end
      specify do
        create_params[:scheduled_activities][:type] = 'invalid'
        expect { described_class.new(create_params) }.to raise_error(/scheduled_activities type/)
      end
    end

    describe 'repeat' do
      %w[never daily weekly monthly customWeekly].each do |value|
        it "accepts '#{value}' value" do
          create_params[:scheduled_activities][:repeat] = value
          expect { described_class.new(create_params) }.to_not raise_error
        end
      end
      specify do
        create_params[:scheduled_activities][:repeat] = 'invalid'
        expect { described_class.new(create_params) }.to raise_error(/scheduled_activities repeat/)
      end
    end

    describe 'expire' do
      %w[never afterDate afterCount].each do |value|
        it "accepts '#{value}' value" do
          create_params[:scheduled_activities][:expire] = value
          expect { described_class.new(create_params) }.to_not raise_error
        end
      end
      specify do
        create_params[:scheduled_activities][:expire] = 'invalid'
        expect { described_class.new(create_params) }.to raise_error(/scheduled_activities expire/)
      end
    end

    describe 'expire_count' do
      it 'requires integer value' do
        create_params[:scheduled_activities][:expire_count] = 'invalid'
        expect { described_class.new(create_params) }.to raise_error(/scheduled_activities expire_count/)
      end

      it 'does not allow zero' do
        create_params[:scheduled_activities][:expire_count] = 0
        expect { described_class.new(create_params) }.to raise_error(/scheduled_activities expire_count/)
      end

      it 'does not allow negatives' do
        create_params[:scheduled_activities][:expire_count] = -1
        expect { described_class.new(create_params) }.to raise_error(/scheduled_activities expire_count/)
      end
    end
  end
end
