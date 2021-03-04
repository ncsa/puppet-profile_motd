# profile_motd

## Reference

### `profile_motd`

#### Parameters

##### `next_maintenance`

Tuple with two date stamps, e.g., '2017-10-19T08:00:00'
First element may be 'none' to prevent information about Next 
maintenance from showing (e.g., if next maintenance is distant).
Valid options: 'tuple array of strings'.

Default: 'none'.

##### `next_maintenance_timezone`

Timezone used for `next_maintenance`. Valid options: 'string'.

Default: 'CT'.

##### `next_maintenance_details`

More details about the `next_maintenance`. Valid options: 'string'.

Default: ''.

##### `notice`

An additional message to add to the end of the motd. Valid options: 'string'.

Default: ''.
