require_relative '../../puppet_x/century_link/property/read_only'

Puppet::Type.newtype(:clc_template) do
  desc 'CenturyLink template'

  newparam(:name) do
    desc 'Name of the template'
  end

  newproperty(:datacenter, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'Template datacenter'
  end

  newproperty(:description, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'Description of the template'
  end

  newproperty(:os_type, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'Template os type'
  end

  newproperty(:storage_size_gb, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'The amount of storage allocated for the primary OS root drive'
  end

  newproperty(:capabilities, parent: PuppetX::CenturyLink::Property::ReadOnly) do
  	desc 'Template deployment capabilities'
  end
end