require 'puppet/parameter/boolean'
require_relative '../../puppet_x/century_link/property/custom_field'
require_relative '../../puppet_x/century_link/property/read_only'
require_relative '../../puppet_x/century_link/property/hash'

Puppet::Type.newtype(:clc_server) do
  desc 'CenturyLink cloud virtual machine instance'

  newproperty(:ensure) do
    newvalue(:present) do
      provider.create unless provider.started?
    end
    newvalue(:absent) do
      provider.destroy if provider.exists?
    end
    newvalue(:started) do
      if provider.exists?
        provider.start unless provider.started?
      else
        provider.create
      end
    end
    newvalue(:stopped) do
      if provider.exists?
        provider.stop unless provider.stopped?
      else
        provider.create
        provider.stop
      end
    end
    newvalue(:paused) do
      if provider.exists?
        provider.pause unless provider.paused?
      else
        provider.create
        provider.pause
      end
    end
    def change_to_s(current, desired)
      current = :started if current == :present
      desired = current if desired == :present and current != :absent
      current == desired ? current : "changed #{current} to #{desired}"
    end
    def insync?(is)
      is.to_s == should.to_s or
        (is.to_s == 'started' and should.to_s == 'present') or
        (is.to_s == 'stopped' and should.to_s == 'present') or
        (is.to_s == 'paused' and should.to_s == 'present')
    end
  end

  newparam(:name) do
    desc 'Name of the server'
    validate do |value|
      fail 'name should be a string' unless value.is_a?(String)
      fail 'server must have a name' if value.strip == ''

      if value.length < 1 || value.length > 8
        fail 'name length should be minimum length of 1 and a maximum length of 8'
      end
    end
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
      if value
        fail 'group_id should be a string' unless value.is_a?(String)
        fail 'server must have a group_id' if value.strip == ''
      end
    end
  end

  newproperty(:group) do
    desc 'Name of the parent group'
    validate do |value|
      if value
        fail 'group should be a string' unless value.is_a?(String)
        fail 'server must have a group' if value.strip == ''
      end
    end
  end

  validate do
    group = self[:group]
    group_id = self[:group_id]

    if group.nil? && group_id.nil?
      fail 'server must have a group or group_id'
    end
  end

  newparam(:source_server_id) do
    desc 'ID of the server to use a source. May be the ID of a template'
    validate do |value|
      fail 'source_server_id should be a string' unless value.is_a?(String)
      fail 'server must have a source_server_id' if value.strip == ''
    end
  end

  newparam(:managed, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'Whether to create the server as managed or not'
    defaultto :false
  end

  newparam(:managed_backup, :boolean => true, :parent => Puppet::Parameter::Boolean) do
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

  newparam(:primary_dns) do
    desc 'Primary DNS to set on the server'
  end

  newparam(:secondary_dns) do
    desc 'Secondary DNS to set on the server'
  end

  newparam(:network_id) do
    desc 'ID of the network to which to deploy the server. If not provided, a network will be chosen automatically'
  end

  newparam(:network) do
    desc 'Network to which to deploy the server'
  end

  newparam(:ip_address) do
    desc 'IP address to assign to the server. If not provided, one will be assigned automatically'
    validate do |value|
      fail 'ip_address must be a valid ipv4 address' unless value =~ Resolv::IPv4::Regex
    end
  end

  newparam(:password) do
    desc 'Password of administrator or root user on server'
  end

  newparam(:source_server_password) do
    desc 'Password of the source server, used only when creating a clone from an existing server'
  end

  newproperty(:id, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'The CLC generated id for the server'
  end

  newparam(:custom_fields, parent: PuppetX::CenturyLink::Property::CustomField, array_matching: :all) do
    desc 'Collection of custom field ID-value pairs to set for the server'
  end

  newproperty(:public_ip_address, parent: PuppetX::CenturyLink::Property::Hash) do
    desc 'Public IP address'
    validate do |value|
      return if value == 'absent'

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
    def insync?(is)
      (is.to_s == 'absent' && should.to_s == 'absent') ||
        (is.is_a?(::Hash) && should.is_a?(::Hash))
    end
  end

  newproperty(:ip_addresses, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'Server ip addresses'
  end

  newparam(:disks) do
    desc 'Collection of disk parameters'
  end

  newproperty(:location, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'Server location'
  end

  newproperty(:os_type, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'Server os type'
  end

  newproperty(:os, parent: PuppetX::CenturyLink::Property::ReadOnly) do
    desc 'Server os'
  end

  autorequire(:clc_group) do
    self[:group]
  end

  autorequire(:clc_network) do
    self[:network]
  end
end
