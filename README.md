# profile_motd

![pdk-validate](https://github.com/ncsa/puppet-profile_motd/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_motd/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure motd

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with profile_motd](#setup)
    * [What profile_motd affects](#what-profile_motd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with profile_motd](#beginning-with-profile_motd)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This puppet profile customizes a host's message of the day (motd).

## Setup

### What profile_system_auth affects

* `/etc/motd`

### Beginning with profile_system_auth

Include profile_motd in a puppet profile file:
```
include ::profile_motd
```

## Usage

The goal is that no paramters are required to be set. The default paramters should work for most NCSA deployments out of the box.

But there are two sets of parameters you may desire to override.

### Add an extra notice to `motd`

You can add extra content to the end of the `motd` by setting the `notice` parameter to some string. This is useful for displaying extra information to users of the host.

### Notify users of an upcoming maintenance

You can add a notice that the server will be undergoing maintenance by setting the following parameters. See [REFERENCE.md](REFERENCE.md) for more details about these parameters.

* `next_maintenance` - Tuple array with two date stamps, e.g., '2017-10-19T08:00:00'
* `next_maintenance_details` - More details about the `next_maintenance`.
* `next_maintenance_timezone` - Timezone used for `next_maintenance`.

## Reference

See: [REFERENCE.md](REFERENCE.md)

## Limitations

n/a

## Development

This Common Puppet Profile is managed by NCSA for internal usage.
