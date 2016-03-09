#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Reference](#reference)
  * [Types](#types)
  * [Parameters](#parameters)
5. [Limitations](#limitations)

## Overview

The clc module manages CenturyLink Cloud resources to build out cloud infrastructure.

## Description

CenturyLink Cloud exposes a powerful API for creating and managing its Infrastructure as a Service platform.
The aws module allows you to drive that API using Puppet code.
In the simplest case, this allows you to manage CLC serveers from Puppet code.
Also it allows to you to describe other resources (like resource groups, networks) and to model the relationships between different components.

## Setup

0. Install the required gems

   ```
   /opt/puppetlabs/puppet/bin/gem install hocon --no-ri --no-rdoc
   ```

   On versions of Puppet Enterprise older than 2015.2.0, use the older path to the `gem` binary:

   ```
   /opt/puppet/bin/gem install hocon --versiom='~>1.0.0' --no-ri --no-rdoc
   ```

0. Set these environment variables for your CenturyLink Cloud access credentials:

    ```
    export CLC_USERNAME=your_username
    export CLC_PASSWORD=your_password
    ```

    Alternatively, you can provide the information in a configuration file of [HOCON format](https://github.com/typesafehub/config). Store this as clc.conf in the relevant [confdir](https://docs.puppetlabs.com/puppet/latest/reference/dirs_confdir.html). This should be:

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

0. Finally, install the module with:

    ```
    puppet module install centurylink-clc
    ```

## Usage

### Creating resources

*Set up a server*:

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

*Set up a group*:

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

Also you can refer group by name:

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
* `clc_template`: A CenturyLink Cloud template. Work only for retrieval using puppet resource CLI.
* `clc_dc`: A CenturyLink Cloud datacenter. Work only for retrieval using puppet resource CLI.

### Parameters

#### Type: clc_server

##### `ensure`

Specifies the basic state of the resource. Valid values are 'present', 'absent', 'started', 'stopped', 'paused'.

Values have the following effects:

* 'present': Ensure that the server exists in either the started or stopped or paused
  state. If the server doesn't yet exist, a new one is created.
* 'started': Ensures that the server is up and running. If the server
  doesn't yet exist, a new one is created. This
  can be used to resume paused servers.
* 'stopped': Ensures that the server is created, but is not running. This
  can be used to shut down running servers.
* 'paused': Ensures that the server is created, but is paused. This
  can be used to pause running servers.
* 'absent': Ensures that the server doesn't exist on CenturyLink Cloud.

##### `cpu`

Specifies the number of CPU cores. Valid values are in 1..16 range.

##### `memory`

Specifies the amount of RAM (in gigabytes). Valid values are in 1..128 range.

##### `group_id`

ID of the parent group. Could be empty if `group` specified.

##### `group`

Name of the parent group. Could be empty if `group_id` specified.

##### `source_server_id`

*Required* ID of the server to use a source. May be the ID of a template, or when cloning, an existing server ID

##### `managed`

Boolean. Whether to create the server as managed or not. Default to false.

##### `managed_backup`

Boolean. Whether to add managed backup to the server. Must be a managed server. Default to false.

##### `type`

Type of server to create. Valid values are 'standard', 'hyperscale' or 'vareMetal'. Default to 'standard'.

##### `storage_type`

Type of storage for server. Valid values are 'standard', 'premium' or 'hyperscale'.

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

Password of the source server, used only when creating a clone from an existing server (e.g. `source_server_id` referencing exiting server).

##### `custom_fields`

Collection of custom field ID-value pairs to set for the server.

##### `public_ip_address`

Public IP address settings. Valid values are settings hash or 'absent'.

Values:

* settings hash:
    hash with two keys
    - ports: array of hashes with protocol/port pairs
    - source_restrictions: array of hashes with source restrictions cidr

    Example:
    ```
    public_ip_address => {
        ports => [{protocol => TCP, port => 80}, {protocol => TCP, port => 443}],
        source_restrictions => [{cidr => '10.0.0.0/24'}]
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

_Read only_ Friendly name of the Operating System the server is running.

##### `os`

_Read only_ Server os.


## Limitations

This module requires Ruby 1.9 or later and is only tested on Puppet versions 4.3 and later.
