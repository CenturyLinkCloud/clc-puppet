require 'puppet/parameter/boolean'
require_relative '../../puppet_x/century_link/property/custom_field'
require_relative '../../puppet_x/century_link/property/read_only'

Puppet::Type.newtype(:clc_network) do
  desc 'CenturyLink cloud network'

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

  newparam(:datacenter) do
    desc 'Parent data center'
    validate do |value|
      fail 'datacenter should be a string' unless value.is_a?(String)
      fail 'group must have a datacenter' if value.strip == ''
    end
  end

  newproperty(:id, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'The CLC generated id for the network'
  end
end
