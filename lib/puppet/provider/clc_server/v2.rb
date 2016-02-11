require_relative '../../../puppet_x/century_link/clc'

Puppet::Type.type(:clc_server).provide(:v2, parent: PuppetX::CenturyLink::Clc) do
  def self.instances
    raise NotImplementedError
  end

  def create
    Puppet.info("Starting server #{name}")

    params = {
      'name'           => name,
      'type'           => resource[:type],
      'groupId'        => resource[:group_id],
      'sourceServerId' => resource[:source_server_id],
      'cpu'            => resource[:cpu],
      'memoryGB'       => resource[:memory],
    }

    links = client.create_server(params)
    client.wait_for(links['operation']['id'])
    server = client.follow(links['resource'])

    @property_hash[:instance_id] = server['id']
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting derver #{name}")

    raise NotImplementedError
  end
end
