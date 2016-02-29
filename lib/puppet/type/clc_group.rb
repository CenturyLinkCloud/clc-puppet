require 'puppet/parameter/boolean'
require_relative '../../puppet_x/century_link/property/custom_field'
require_relative '../../puppet_x/century_link/property/read_only'

Puppet::Type.newtype(:clc_group) do
  desc 'CenturyLink cloud billing group'

  ensurable

  newparam(:name) do
    desc 'Name of the group'
    validate do |value|
      fail 'name should be a string' unless value.is_a?(String)
      fail 'group must have a name' if value.strip == ''
    end
  end

  newproperty(:description) do
    desc 'User-defined description of this group'
  end

  newproperty(:servers_count, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'Number of servers this group contains'
  end

  newparam(:parent_group_id) do
    desc 'ID of the parent group'
    validate do |value|
      fail 'parent_group_id should be a string' unless value.is_a?(String)
      fail 'group must have a parent_group_id' if value.strip == ''
    end
  end

  newparam(:parent_group) do
    desc 'Name of the parent group'
    validate do |value|
      fail 'parent_group should be a string' unless value.is_a?(String)
      fail 'group must have a parent_group' if value.strip == ''
    end
  end

  newproperty(:datacenter) do
    desc 'Parent data center'
    validate do |value|
      fail 'datacenter should be a string' unless value.is_a?(String)
      fail 'group must have a datacenter' if value.strip == ''
    end
  end

  newproperty(:id, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'The CLC generated id for the group'
  end

  newproperty(:custom_fields, parent: PuppetX::CenturyLink::Property::CustomField, array_matching: :all) do
    desc 'Collection of custom field ID-value pairs to set for the group'
  end

  newparam(:defaults) do
    desc 'Sets the defaults for a group'
    validate do |value|
      cpu = value[:cpu] || value['cpu']
      if cpu
        fail 'default cpu should be an integer' unless cpu.is_a?(Fixnum)
        fail 'default cpu must be in 1..16 range' if cpu < 1 || cpu > 16
      end

      memory = value[:memory] || value['memory']
      if memory
        fail 'default memory should be an integer' unless memory.is_a?(Fixnum)
        fail 'default memory must be in 1..128 range' if memory < 1 || memory > 128
      end

      [:primary_dns, :secondary_dns, :network_id, :template_name].each do |field|
        field_value = value[field] || value[field.to_s]
        if field_value
          fail "default #{field} should be a string" unless field_value.is_a?(String)
        end
      end
    end
  end

  autorequire(:clc_group) do
    self[:parent_group]
  end
end
