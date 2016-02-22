require_relative '../../../puppet_x/century_link/clc'
require_relative '../../../puppet_x/century_link/prefetch_error'

Puppet::Type.type(:clc_server).provide(:v2, parent: PuppetX::CenturyLink::Clc) do
  mk_resource_methods

  read_only(:server_id, :os_type, :os, :location, :ip_addresses)

  def self.instances
    begin
      servers = client.list_servers
      servers.delete_if { |server| server['description'].nil? || server['description'] == '' }
      servers.map { |server| new(server_to_hash(server)) }
    rescue Timeout::Error, StandardError => e
      raise PuppetX::CenturyLink::PrefetchError.new(self.resource_type.name.to_s, e)
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def self.server_to_hash(server)
    details = server['details'] || {}
    group = client.show_group(server['groupId'])

    hash = {
      server_id:         server['id'],
      name:              server['description'],
      type:              server['type'],
      storage_type:      server['storageType'],
      location:          server['locationId'],
      os_type:           server['osType'],
      os:                server['os'],
      group_id:          server['groupId'],
      cpu:               details['cpu'],
      memory:            details['memoryMB'] / 1024,
      public_ip_address: public_ip_address_hash(server['id'], details),
      ip_addresses:      details['ipAddresses'],
      group:             group['name'],
      ensure:            details['powerState'].to_sym,
    }
    public_ip_hash = public_ip_address_hash(server['id'], details)
    hash[:public_ip_address] = public_ip_hash if public_ip_hash
    hash
  end

  def self.public_ip_address_hash(server_id, server_details)
    ip_addresses = server_details['ipAddresses']
    public_ip = ip_addresses.find { |addr| !addr['public'].nil? }
    return nil if public_ip.nil?

    ip_data = client.show_public_ip(server_id, public_ip['public'])
    {
      'internal_ip'         => ip_data['internal'],
      'ports'               => ip_data['ports'],
      'source_restrictions' => ip_data['sourceRestrictions'],
    }
  end

  def exists?
    Puppet.info("Checking if server #{name} exists")
    started? || stopped? || paused?
  end

  def started?
    Puppet.info("Checking if server #{name} is started")
    [:present, :started].include?(@property_hash[:ensure])
  end

  def stopped?
    Puppet.info("Checking if server #{name} is stopped")
    @property_hash[:ensure] == :stopped
  end

  def paused?
    Puppet.info("Checking if server #{name} is paused")
    @property_hash[:ensure] == :paused
  end

  def create
    Puppet.info("Starting server #{name}")

    fail("source_server_id can't be blank") if resource[:source_server_id].nil?

    config = {
      'name'                 => name,
      'description'          => name,
      'type'                 => resource[:type],
      'sourceServerId'       => resource[:source_server_id],
      'cpu'                  => resource[:cpu],
      'memoryGB'             => resource[:memory],
      'storageType'          => resource[:storage_type],
      'isManagedOS'          => resource[:managed],
      'isManagedBackup'      => resource[:managed_backup],
      'primaryDns'           => resource[:primary_dns],
      'secondaryDns'         => resource[:secondary_dns],
      'networkId'            => resource[:network_id],
      'ipAddress'            => resource[:ip_address],
      'password'             => resource[:password],
      'sourceServerPassword' => resource[:source_server_password],
      'customFields'         => resource[:custom_fields],
    }
    config = config_with_group(config)
    config = config_with_disks(config)

    server = client.create_server(remove_null_values(config))

    @property_hash[:server_id] = server['id']
    @property_hash[:ensure] = :present

    if resource[:public_ip_address]
      params = public_ip_config(resource[:public_ip_address])
      client.create_public_ip(@property_hash[:server_id], params)
    end

    true
  end

  def memory=(value)
    client.set_server_property(server_id, 'memory', value.to_s)
    @property_hash[:memory] = value
  end

  def cpu=(value)
    client.set_server_property(server_id, 'cpu', value.to_s)
    @property_hash[:cpu] = value
  end

  def destroy
    Puppet.info("Deleting server #{name}")
    client.delete_server(server_id)
    @property_hash[:ensure] = :absent
    true
  end

  def start
    Puppet.info("Starting server #{name}")
    client.power_on_server(server_id)
    @property_hash[:ensure] = :started
  end

  def stop
    Puppet.info("Stopping server #{name}")
    client.shutdown_server(server_id)
    @property_hash[:ensure] = :stopped
  end

  def pause
    Puppet.info("Pausing server #{name}")
    client.pause_server(server_id)
    @property_hash[:ensure] = :paused
  end

  private

  def public_ip_config(config)
    remove_null_values({
      'ports'              => config[:ports] || config['ports'],
      'sourceRestrictions' => config[:source_restrictions] || config['source_restrictions'],
    })
  end

  def config_with_group(config)
    if resource[:group_id]
      config['groupId'] = resource[:group_id]
    elsif resource[:group]
      config['groupId'] = find_group_by_name(resource[:group])['id']
    end
    config
  end

  def config_with_disks(config)
    if resource[:disks]
      config['additionalDisks'] = resource[:disks]
    end
    config
  end
end
