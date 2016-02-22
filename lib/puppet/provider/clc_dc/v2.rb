require_relative '../../../puppet_x/century_link/clc'
require_relative '../../../puppet_x/century_link/prefetch_error'

Puppet::Type.type(:clc_dc).provide(:v2, parent: PuppetX::CenturyLink::Clc) do
  mk_resource_methods

  read_only(:name, :id)

  def self.instances
    begin
      dcs = client.list_datacenters(false)
      dcs.map { |dc| new(dc_to_hash(dc)) }
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

  def self.dc_to_hash(dc)
    {
      id:   dc['id'],
      name: dc['name'],
    }
  end
end
