require 'puppet/parameter/boolean'
require 'puppet_x/century_link/property/custom_field'
require 'puppet_x/century_link/property/hash'

Puppet::Type.newtype(:clc_server) do
  desc 'CenturyLink cloud virtual machine instance'

  ensurable

  newparam(:name) do
    desc 'Name of the server'
    validate do |value|
      fail 'name should be a string' unless value.is_a?(String)
      fail 'server must have a name' if value.strip == ''
    end
  end

  newproperty(:description) do
    desc 'User-defined description of this server'
  end

  newproperty(:cpu) do
    desc 'Number of processors to configure the server with (1-16)'
    validate do |value|
      fail 'cpu should be an integer' unless value.is_a?(Fixnum)
      fail 'cpu must be in 1..16 range' if value < 1 || value > 16
    end
  end

  newproperty(:memory) do
    desc 'Number of GB of memory to configure the server with'
    validate do |value|
      fail 'memory should be an integer' unless value.is_a?(Fixnum)
      fail 'memory must be in 1..128 range' if value < 1 || value > 128
    end
  end

  newproperty(:group_id) do
    desc 'ID of the parent group'
    validate do |value|
      fail 'group_id should be a string' unless value.is_a?(String)
      fail 'server must have a group_id' if value.strip == ''
    end
  end

  newproperty(:source_server_id) do
    desc 'ID of the server to use a source. May be the ID of a template, or when cloning, an existing server ID'
    validate do |value|
      fail 'source_server_id should be a string' unless value.is_a?(String)
      fail 'server must have a source_server_id' if value.strip == ''
    end
  end

  newproperty(:managed, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'Whether to create the server as managed or not'
    defaultto :false
  end

  newproperty(:managed_backup, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'Whether to add managed backup to the server. Must be a managed OS server'
    defaultto :false
  end

  validate do
    if self[:managed_backup] && !self[:managed]
      fail "you can't set managed_backup to true while managed is false"
    end
  end

  newproperty(:type) do
    desc 'Whether to create a standard, hyperscale, or bareMetal server'
    newvalues(:standard, :hyperscale, :bareMetal)
    defaultto :standard
  end

  newproperty(:storage_type) do
    desc 'Storage type'
    newvalues(:standard, :premium, :hyperscale)
  end

  newproperty(:primary_dns) do
    desc 'Primary DNS to set on the server'
  end

  newproperty(:secondary_dns) do
    desc 'Secondary DNS to set on the server'
  end

  newproperty(:network_id) do
    desc 'ID of the network to which to deploy the server. If not provided, a network will be chosen automatically'
  end

  newproperty(:ip_address) do
    desc 'IP address to assign to the server. If not provided, one will be assigned automatically'
    validate do |value|
      fail 'ip_address must be a valid ipv4 address' unless value =~ Resolv::IPv4::Regex
    end
  end

  newproperty(:password) do
    desc 'Password of administrator or root user on server'
  end

  newproperty(:source_server_password) do
    desc 'Password of the source server, used only when creating a clone from an existing server'
  end

  newproperty(:server_id) do
    desc 'The CLC generated id for the server'
    validate do |value|
      fail 'server_id is read-only'
    end
  end

  newproperty(:custom_fields, parent: PuppetX::CenturyLink::Property::CustomField, array_matching: :all) do
    desc 'Collection of custom field ID-value pairs to set for the server'
  end

  newproperty(:public_ip_address, parent: PuppetX::CenturyLink::Property::Hash) do
    desc 'Public IP address'
    validate do |value|
      super(value)

      ports = value[:ports] || value['ports']
      fail 'ports must be an array' unless ports.is_a?(Array)
      ports.each do |port|
        fail 'ports entry must be a hash' unless port.is_a?(::Hash)
      end

      source_restrictions = value[:source_restrictions] || value['source_restrictions']
      if source_restrictions
        fail 'source_restrictions must be an array' unless source_restrictions.is_a?(Array)
        source_restrictions.each do |restriction|
          fail 'source_restrictions entry must be a hash' unless restriction.is_a?(::Hash)
        end
      end
    end
  end
end
