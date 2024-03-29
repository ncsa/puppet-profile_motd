# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`profile_motd`](#profile_motd): Configure motd

## Classes

### <a name="profile_motd"></a>`profile_motd`

Configure motd

#### Examples

##### 

```puppet
include profile_motd
```

#### Parameters

The following parameters are available in the `profile_motd` class:

* [`hide_enc`](#-profile_motd--hide_enc)
* [`next_maintenance`](#-profile_motd--next_maintenance)
* [`next_maintenance_timezone`](#-profile_motd--next_maintenance_timezone)
* [`next_maintenance_details`](#-profile_motd--next_maintenance_details)
* [`notice`](#-profile_motd--notice)
* [`files_absent`](#-profile_motd--files_absent)

##### <a name="-profile_motd--hide_enc"></a>`hide_enc`

Data type: `Boolean`

If set, hide ENC data from the motd.
Instead display ENC data for the root user via profile.d file

##### <a name="-profile_motd--next_maintenance"></a>`next_maintenance`

Data type: `Array[String]`

tuple with two date stamps, e.g., '2017-10-19T08:00:00'
first element may be 'none' to prevent information about
next maintenance from showing (e.g., if next maintenance is distant)

##### <a name="-profile_motd--next_maintenance_timezone"></a>`next_maintenance_timezone`

Data type: `String`

timezone used for next_maintenance

##### <a name="-profile_motd--next_maintenance_details"></a>`next_maintenance_details`

Data type: `String`

more details about next_maintenance

##### <a name="-profile_motd--notice"></a>`notice`

Data type: `String`

An additional message to add to the end of the motd

##### <a name="-profile_motd--files_absent"></a>`files_absent`

Data type: `Hash`

Files to remove related to motd. Hash of parameters for file resource.

