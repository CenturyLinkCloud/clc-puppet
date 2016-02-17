require_relative '../../../puppet_x/century_link/clc'

Puppet::Type.type(:clc_server).provide(:v2, parent: PuppetX::CenturyLink::Clc) do
  mk_resource_methods

  read_only(:server_id)

  def self.instances
    servers = client.list_servers
    servers.delete_if { |server| server['description'].nil? || server['description'] == '' }
    servers.map { |server| new(server_to_hash(server)) }
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
    group = client.get_group(server['groupId'])

    {
      server_id: server['id'],
      name:      server['description'],
      cpu:       details['cpu'],
      memory:    details['memoryMB'] / 1024,
      group_id:  server['groupId'],
      group:     group['name'],
      ensure:    details['powerState'].to_sym,
    }
  end

  def exists?
    Puppet.info("Checking if server #{name} exists")
    started? || stopped? || paused? || maintenance?
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
    if stopped? || paused?
      start
    else
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

      server = client.create_server(remove_null_values(config))

      @property_hash[:server_id] = server['id']
      @property_hash[:ensure] = :present

      if resource[:public_ip_address]
        client.create_public_ip(@property_hash[:server_id], public_ip_config(resource[:public_ip_address]))
      end

      true
    end
  end

  def destroy
    Puppet.info("Deleting server #{name}")
    client.delete_server(server_id)
    @property_hash[:ensure] = :absent
    true
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

  def start
    Puppet.info("Starting server #{name}")

    client.power_on_server(server_id)

    @property_hash[:ensure] = :started
  end

  def public_ip_config(config)
    remove_null_values({
      'ports'              => config[:ports],
      'sourceRestrictions' => config[:source_restrictions]
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

  def find_group_by_name(name)
    groups = client.list_groups
    matching_groups = groups.select { |group| group['name'] == name }

    if matching_groups.empty?
      raise Puppet::Error "Group '#{resource[:group]}' not found"
    end
    if matching_groups.size > 1
      raise Puppet::Error, "There are #{matching_groups.size} groups " \
        "matching '#{resource[:group]}'. Consider using group_id"
    end

    matching_groups.first
  end
end
