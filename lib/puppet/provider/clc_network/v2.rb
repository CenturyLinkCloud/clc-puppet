require_relative '../../../puppet_x/century_link/clc'
require_relative '../../../puppet_x/century_link/prefetch_error'

Puppet::Type.type(:clc_network).provide(:v2, parent: PuppetX::CenturyLink::Clc) do
  mk_resource_methods

  read_only(:id)

  def self.instances
    begin
      networks = client.list_networks
      networks.map { |network| new(network_to_hash(network)) }
    rescue Timeout::Error, StandardError => e
      raise PuppetX::CenturyLink::PrefetchError.new(self.resource_type.name.to_s, e)
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov if resource[:datacenter].downcase == prov.datacenter.downcase
      end
    end
  end

  def self.network_to_hash(network)
    {
      id:          network['id'],
      name:        network['name'],
      description: network['description'],
      datacenter:  network['datacenter'],
      ensure:      :present,
    }
  end

  def exists?
    Puppet.info("Checking if network #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating network #{name}")

    fail("datacenter can't be blank") if resource[:datacenter].nil?

    params = {
      'name'        => name,
      'description' => resource[:description]
    }

    network = client.claim_network(resource[:datacenter])
    client.update_network(resource[:datacenter], network['id'], remove_null_values(params))

    @property_hash[:id] = network['id']
    @property_hash[:ensure] = :present

    true
  end

  def destroy
    Puppet.info("Deleting network #{name}")

    begin
      client.release_network(datacenter, id)
    rescue Faraday::TimeoutError
      # Relase network is sync operation. Just ignore read timeout
    end

    @property_hash[:ensure] = :absent
  end
end
