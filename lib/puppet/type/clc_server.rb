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

  newparam(:cpu) do
    desc 'Number of processors to configure the server with (1-16)'
    validate do |value|
      fail 'cpu should be an integer' unless value.is_a?(Fixnum)
      fail 'cpu must be in 1..16 range' if value < 1 || value > 16
    end
  end

  newparam(:memory) do
    desc 'Number of GB of memory to configure the server with'
    validate do |value|
      fail 'memory should be an integer' unless value.is_a?(Fixnum)
      fail 'memory must be in 1..128 range' if value < 1 || value > 128
    end
  end

  newparam(:managed, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'Whether to create the server as managed or not'
    defaultto :false
  end

  newparam(:type) do
    desc 'Whether to create a standard, hyperscale, or bareMetal server'
    newvalues(:standard, :hyperscale, :bareMetal)
    defaultto :standard
  end

  newparam(:primary_dns) do
    desc 'Primary DNS to set on the server.'
  end

  newparam(:secondary_dns) do
    desc 'Secondary DNS to set on the server.'
  end

  newparam(:ip_address) do
    desc 'IP address to assign to the server. If not provided, one will be assigned automatically'
  end

  newparam(:password) do
    desc 'Password of administrator or root user on server'
  end
end
