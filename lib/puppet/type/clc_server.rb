require 'puppet/parameter/boolean'

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

  newparam(:description) do
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

  newproperty(:type) do
    desc 'Whether to create a standard, hyperscale, or bareMetal server'
    newvalues(:standard, :hyperscale, :bareMetal)
    defaultto :standard
  end

  newproperty(:primary_dns) do
    desc 'Primary DNS to set on the server.'
  end

  newproperty(:secondary_dns) do
    desc 'Secondary DNS to set on the server.'
  end

  newproperty(:ip_address) do
    desc 'IP address to assign to the server. If not provided, one will be assigned automatically'
  end

  newproperty(:password) do
    desc 'Password of administrator or root user on server'
  end

  newproperty(:server_id) do
    desc 'The CLC generated id for the server'
    validate do |value|
      fail 'server_id is read-only'
    end
  end
end
