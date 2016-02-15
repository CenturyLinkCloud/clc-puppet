require_relative '../../../puppet_x/century_link/clc'

Puppet::Type.type(:clc_server).provide(:v2, parent: PuppetX::CenturyLink::Clc) do
  mk_resource_methods

  read_only(:server_id)

  def self.instances
    raise NotImplementedError
  end

  def create
    Puppet.info("Starting server #{name}")

    params = {
      'name'                 => name,
      'description'          => resource[:description],
      'type'                 => resource[:type],
      'groupId'              => resource[:group_id],
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

    server = client.create_server(remove_null_values(params))

    @property_hash[:server_id] = server['id']
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting server #{name}")

    client.delete_server(server_id)

    @property_hash[:ensure] = :absent
  end
end
