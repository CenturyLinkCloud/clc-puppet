require_relative '../../../puppet_x/century_link/clc'
require_relative '../../../puppet_x/century_link/prefetch_error'

Puppet::Type.type(:clc_template).provide(:v2, parent: PuppetX::CenturyLink::Clc) do
  mk_resource_methods

  read_only(:id)

  def self.instances
    begin
      templates = client.list_templates
      x = templates.map do |dc_id, templates|
        templates.map do |template|
          template['locationId'] = dc_id
          new(template_to_hash(template))
        end
      end.flatten
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

  def self.template_to_hash(template)
    {
      name:            "#{template['locationId']}-#{template['name']}",
      datacenter:      template['locationId'],
      description:     template['description'],
      os_type:         template['osType'],
      storage_size_gb: template['storageSizeGb'],
    }
  end
end
