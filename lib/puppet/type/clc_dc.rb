require_relative '../../puppet_x/century_link/property/read_only'

Puppet::Type.newtype(:clc_dc) do
  desc 'CenturyLink datacenter'

  newparam(:name) do
    desc 'Name of the datacenter'
  end

  newproperty(:id, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'Id of the datacenter'
  end
end