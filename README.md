#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Reference](#reference)
  * [Types](#types)
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

## Limitations

This module requires Ruby 1.9 or later and is only tested on Puppet versions 4.3 and later.
