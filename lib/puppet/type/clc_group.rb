require 'puppet/parameter/boolean'
require 'puppet_x/century_link/property/custom_field'

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

  newproperty(:parent_group_id) do
    desc 'ID of the parent group'
    validate do |value|
      fail 'parent_group_id should be a string' unless value.is_a?(String)
      fail 'group must have a parent_group_id' if value.strip == ''
    end
  end

  newproperty(:group_id) do
    desc 'The CLC generated id for the group'
    validate do |value|
      fail 'group_id is read-only'
    end
  end

  newproperty(:custom_fields, parent: PuppetX::CenturyLink::Property::CustomField, array_matching: :all) do
    desc 'Collection of custom field ID-value pairs to set for the group'
  end
end