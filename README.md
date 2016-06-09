#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#description)
3. [Requirements](#requirements)
4. [Setup](#setup)
5. [Usage](#usage)
6. [Reference](#reference)
  * [Types](#types)
  * [Parameters](#parameters)
7. [Limitations](#limitations)
8. [Contributing](#contributing)
9. [License](#license)

## Overview

The CLC module manages CenturyLink Cloud resources to build out cloud infrastructure.

## Description

CenturyLink Cloud exposes a powerful API for creating and managing its Infrastructure-as-a-Service platform.
In the simplest case, this allows you to manage CLC servers from Puppet code.
It also allows to you to describe other resources (like resource groups, networks) and to model the relationships between different components.

## Requirements

* Ruby 1.9 and later
* Puppet versions 4.3 and later

## Installation

1. Install the required Ruby gems.

   ```
   /opt/puppetlabs/puppet/bin/gem install hocon --no-ri --no-rdoc
   ```

   On versions of Puppet Enterprise older than 2015.2.0, use the older path to the `gem` binary:

   ```
   /opt/puppet/bin/gem install hocon --no-ri --no-rdoc
   ```

2. Set these environment variables for your CenturyLink Cloud access credentials:

    ```
    export CLC_USERNAME=your_username
    export CLC_PASSWORD=your_password
    ```

    Alternatively, you can provide the information in a configuration file of [HOCON format](https://github.com/typesafehub/config). Store this as clc.conf in the relevant [confdir](https://docs.puppetlabs.com/puppet/latest/reference/dirs_confdir.html).

    This should be:

    * nix Systems: `/etc/puppetlabs/puppet`
    * Windows: `C:\ProgramData\PuppetLabs\puppet\etc`
    * non-root users: `~/.puppetlabs/etc/puppet`

    The file format is:

    ```
    clc: {
      username: "your_username"
      password: "your_password"
    }
    ```

3. Finally, install the module with:

    ```
    puppet module install centurylink-clc
    ```

## Commands

### Creating Resources

#### Set up a server

```
clc_server { 'name-of-server':
  ensure => presebt,
  cpu => 2,
  memory => 4, # in GB
  group_id => '5757349d19c343a88ce9a473fe2522f4',
  source_server_id => 'DEBIAN-7-64-TEMPLATE',
  password => 'pa$$w0rd',
  primary_dns => '4.4.4.4',
  secondary_dns => '8.8.8.8',
  public_ip_address => {
    ports => [{
        protocol => TCP,
        port => 80
    }]
  }
}
```

#### Set up a group

```
clc_group { 'name-of-group':
  ensure      => present,
  description => 'Group description',
  datacenter  => 'VA1'
}
```

Alternatively you can define _parent_group_id_ instead of _datacenter_ to create a subgroup:

```
clc_group { 'name-of-subgroup':
  ensure           => present,
  description      => 'Group description',
  parent_group_id  => '5757349d19c343a88ce9a473fe2522f4'
}
```

Also, you can refer to the group by name:

```
clc_group { 'name-of-parent-group':
  ensure      => present,
  description => 'Parent group description',
  datacenter  => 'VA1'
}

clc_group { 'name-of-subgroup':
  ensure       => present,
  description  => 'Group description',
  parent_group => 'name-of-parent-group'
}
```

## Reference

### Types

* `clc_server`: Manages a server in CenturyLink Cloud.
* `clc_group`: Manages a CenturyLink Cloud group.
* `clc_network`: Manages a CenturyLink Cloud network.
* `clc_template`: A CenturyLink Cloud template. Works only for retrieval using a Puppet resource CLI.
* `clc_dc`: A CenturyLink Cloud datacenter. Work only for retrieval using a Puppet resource CLI.

### Parameters

#### Type: clc_server

##### `ensure`

Specifies the basic state of the resource. Valid values are 'present', 'absent', 'started', 'stopped', 'paused'.

Values have the following effects:

* 'present': Ensures that the server exists in either the started, stopped, or paused state.
  If the server doesn't yet exist, a new one is created.
* 'started': Ensures that the server is up and running. If the server doesn't yet exist, a new one is created.
  This can be used to resume paused servers.
* 'stopped': Ensures that the server is created, but is not running.
  This can be used to shut down running servers.
* 'paused': Ensures that the server is created, but is paused.
  This can be used to pause running servers.
* 'absent': Ensures that the server doesn't exist on CenturyLink Cloud.

##### `cpu`

Specifies the number of CPU cores. Valid values are in the 1..16 range.

##### `memory`

Specifies the amount of RAM (in gigabytes). Valid values are in the 1..128 range.

##### `group_id`

ID of the parent group. Could be empty if `group` is specified.

##### `group`

Name of the parent group. Could be empty if `group_id` is specified.

##### `source_server_id`

*Required* ID of the server to use a source. May be the ID of a template, or when cloning, an existing server ID.

##### `managed`

Boolean. Whether to create the server as managed or not. Defaults to false.

##### `managed_backup`

Boolean. Whether to add managed backup to the server. Must be a managed server. Defaults to false.

##### `type`

Type of server to create. Valid values are 'standard', 'hyperscale', or 'bareMetal'. Defaults to 'standard'.

##### `storage_type`

Type of storage for server. Valid values are 'standard', 'premium', or 'hyperscale'.

##### `primary_dns`

Primary DNS to set on the server.

##### `secondary_dns`

Secondary DNS to set on the server.

##### `network_id`

ID of the network to which to deploy the server.

##### `network`

Name of the network to which to deploy the server.

##### `ip_address`

IP address to assign to the server. If not provided, one will be assigned automatically.

##### `password`

Password of administrator or root user on server. If not provided, one will be generated automatically.

##### `source_server_password`

Password of the source server, used only when creating a clone from an existing server (e.g. `source_server_id` referencing existing server).

##### `custom_fields`

Collection of custom field ID-value pairs to set for the server.

##### `public_ip_address`

Public IP address settings. Valid values are 'settings hash' or 'absent'.

Values:

* settings hash:
    hash with two keys
    - ports: array of hashes with protocol/port pairs
    - source_restrictions: array of hashes with source restrictions cidr

    Example:
    ```
    clc_server { 'test-server':
        ....
        public_ip_address => {
            ports => [{protocol => TCP, port => 80}, {protocol => TCP, port => 443}],
            source_restrictions => [{cidr => '10.0.0.0/24'}]
        }
        ...
    }
    ```
* 'absent': deletes assigned public IP.


##### `id`

_Read only_ ID of the server.

##### `ip_addresses`

_Read only_ Details about IP addresses associated with the server.

##### `disks`

_Read only_ The disks attached to the server.

##### `location`

_Read only_ Data center that this server resides in.

##### `os_type`

_Read only_ Friendly name of the Operating System (OS) that the server is running.

##### `os`

_Read only_ Server OS.


#### Type: clc_group

##### `ensure`

Specifies the basic state of the resource. Valid values are 'present' and 'absent'.

Values have the following effects:

* 'present': Ensure that the group exists. If the group doesn't yet exist, a new one is created.
* 'absent': Ensures that the group doesn't exist on CenturyLink Cloud.

##### `description`

User-defined description of the group.

##### `servers_count`

_Read only_ Number of servers this group contains.

##### `parent_group_id`

ID of the parent group. Could be empty if `parent_group` or `datacenter` is specified.

##### `parent_group`

Name of the parent group. Could be empty if `parent_group_id` or `datacenter` is specified.

##### `datacenter`

Name of the parent datacenter, if specified group will be created as a top-level group in datacenter.
Could be empty if `parent_group_id` or `parent_group` is specified.

##### `id`

_Read only_ ID of the group.

##### `custom_fields`

Collection of custom field ID-value pairs to set for the group.

##### `defaults`

Default values for the group. Value must be a hash.
Valid hash keys are: 'cpu', 'memory', 'primary_dns', 'secondary_dns', 'network_id', and 'template_name'.

* 'cpu': Number of processors to configure the server. Value is an integer within the 1..16 range.
* 'memory': Number of GB of memory to configure the server. Value is an integer within the 1..128 range.
* 'primary_dns': Primary DNS to set on the server.
* 'secondary_dbs': Secondary DNS to set on the server.
* 'network_id': ID of the Network.
* 'template_name': Name of the template to use as the source.

Example:

```
clc_group { 'test-group':
    ...
    defaults => {
        cpu => 2,
        memory => 4,
        primary_dns => '4.4.4.4',
        secondary_dns => '8.8.8.8',
        template_name => 'DEBIAN-7-64-TEMPLATE',
    }
    ...
}

```

##### `scheduled_activities`

Scheduled activities for a group. Value must be an array of hashes.
Valid hash keys are: 'status', 'type', 'begin_date', 'repeat', 'custom_weekly_days', 'expire',
'expire_count', 'expire_date', and 'time_zone_offset'.

* 'status': State of scheduled activity: 'on' or 'off'. _Required_
* 'type': Type of activity: 'archive', 'createsnapshot', 'delete', 'deletesnapshot', 'pause', 'poweron', 'reboot', 'shutdown'. _Required_
* 'begin_date': Time when scheduled activity should start (UTC). _Required_
* 'repeat': How often to repeat: 'never', 'daily', 'weekly', 'monthly', 'customWeekly'. _Required_
* 'custom_weekly_days': An array of strings for the days of the week: 'sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'.
* 'expire': When the scheduled activities are set to expire: 'never', 'afterDate', 'afterCount'. _Required_
* 'expire_count': Number of times scheduled activity should run before expiring.
* 'expire_date': When the scheduled activity should expire (UTC).
* 'time_zone_offset': To display in local time. _Required_


Example:

```
clc_group { 'test-group':
    ...
    scheduled_activities => [
        {
            status => on,
            'type' => reboot,
            begin_date => "2015-11-23T19:41:00.000Z",
            time_zone_offset => "-08:00",
            repeat => weekly,
            expire => never
        },
        {
            status => on,
            'type' => reboot,
            begin_date => "2015-11-23T19:41:00.000Z",
            time_zone_offset => "-08:00",
            repeat => customWeekly,
            expire => never,
            custom_weekly_days => ['mon', 'wed', 'fri']
        }
    ]
    ...
}

```

#### Type: clc_network

##### `ensure`

Specifies the basic state of the resource. Valid values are 'present' and 'absent'.

Values have the following effects:

* 'present': Ensure that the network exists. If the network doesn't yet exist, a new one is created.
* 'absent': Ensures that the network doesn't exist on CenturyLink Cloud.

##### `description`

User-defined description of the network.

##### `datacenter`

Parent data center.

##### `id`

_Read only_ ID of the network.


## Limitations

This module requires Ruby 1.9 or later and is only tested on Puppet versions 4.3 and later.

## Contributing

1. Fork the main repository. https://github.com/CenturyLinkCloud/clc-puppet/fork.
2. Create a feature branch from the master branch. `git checkout -b my-new-feature`
3. Commit your changes to the feature branch. `git commit -am 'Add some feature'`
4. Push to the master branch. `git push origin my-new-feature`
5. Create a new Pull Request (to CenturyLinkCloud/clc-puppet).
6. Specs and Code Style checks should pass before the Code Review.

## License

The project is licensed under the [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
