require_relative '../../../puppet_x/century_link/clc'

Puppet::Type.type(:clc_group).provide(:v2, parent: PuppetX::CenturyLink::Clc) do
  mk_resource_methods

  read_only(:group_id)

  def create
    Puppet.info("Creating group #{name}")

    params = {
      'name'          => name,
      'description'   => resource[:description],
      'parentGroupId' => resource[:parent_group_id],
      'customFields'  => resource[:custom_fields],
    }

    group = client.create_group(params)

    @property_hash[:group_id] = group['id']
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting group #{name}")

    client.delete_group(group_id)

    @property_hash[:ensure] = :absent
  end
end
