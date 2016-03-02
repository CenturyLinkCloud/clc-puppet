require_relative '../../../puppet_x/century_link/clc'
require_relative '../../../puppet_x/century_link/prefetch_error'

Puppet::Type.type(:clc_group).provide(:v2, parent: PuppetX::CenturyLink::Clc) do
  mk_resource_methods

  read_only(:id, :servers_count)

  IGNORE_GROUP_NAMES = ['Archive', 'Templates']

  def self.instances
    begin
      groups = client.list_groups
      groups.map { |group| new(group_to_hash(group)) }
    rescue Timeout::Error, StandardError => e
      raise PuppetX::CenturyLink::PrefetchError.new(self.resource_type.name.to_s, e)
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if !IGNORE_GROUP_NAMES.include?(prov.name) && resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def self.group_to_hash(group)
    {
      id:              group['id'],
      name:            group['name'],
      description:     group['description'],
      custom_fields:   group['customFields'],
      servers_count:   group['serversCount'],
      datacenter:      group['locationId'],
      ensure:          :present,
    }
  end

  def exists?
    Puppet.info("Checking if group #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating group #{name}")

    params = {
      'name'          => name,
      'description'   => resource[:description],
      'parentGroupId' => find_parent_group(resource),
      'customFields'  => resource[:custom_fields],
    }

    group = client.create_group(params)

    @property_hash[:id] = group['id']
    @property_hash[:ensure] = :present

    if resource[:defaults]
      begin
        default_params = remove_null_values(group_defaults(resource[:defaults]))
        client.set_group_defaults(group['id'], default_params)
      rescue
        client.delete_group(group['id'])
        @property_hash[:ensure] = :absent
      end
    end

    if resource[:scheduled_activities]
      begin
        scheduled_activities_params = remove_null_values(group_scheduled_activities(resource[:scheduled_activities]))
        client.set_group_scheduled_activities(group['id'], scheduled_activities_params)
      rescue
        client.delete_group(group['id'])
        @property_hash[:ensure] = :absent
      end
    end

    true
  end

  def destroy
    Puppet.info("Deleting group #{name}")

    client.delete_group(id)

    @property_hash[:ensure] = :absent
  end

  private

  def find_parent_group(params)
    if params[:parent_group_id]
      params[:parent_group_id]
    elsif params[:datacenter]
      group = client.show_hw_group_for_datacenter(params[:datacenter])
      group['id']
    elsif params[:parent_group]
      group = find_group_by_name(params[:parent_group])
      group['id']
    end
  end

  def group_defaults(params)
    {
      'cpu'          => params['cpu'],
      'memoryGb'     => params['memory'],
      'networkId'    => params['network_id'],
      'primaryDns'   => params['primary_dns'],
      'secondaryDns' => params['secondary_dns'],
      'templateName' => params['template_name'],
    }
  end

  def group_scheduled_activities(params)
    {
      'status'           => params['status'],
      'type'             => params['type'],
      'beginDateUTC'     => params['begin_date'],
      'repeat'           => params['repeat'],
      'customWeeklyDays' => params['custom_weekly_days'],
      'expire'           => params['expire'],
      'expireCount'      => params['expire_count'],
      'expireDateUTC'    => params['expire_date'],
      'timeZoneOffset'   => params['time_zone_offset']
    }
  end
end
