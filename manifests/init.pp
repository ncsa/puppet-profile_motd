# @summary Configure motd
#
# @param hide_enc
#   If set, hide ENC data from the motd.
#   Instead display ENC data for the root user via profile.d file
#
# @param next_maintenance
#   tuple with two date stamps, e.g., '2017-10-19T08:00:00'
#   first element may be 'none' to prevent information about
#   next maintenance from showing (e.g., if next maintenance is distant)
#
# @param next_maintenance_timezone
#   timezone used for next_maintenance
#
# @param next_maintenance_details
#   more details about next_maintenance
#
# @param notice
#   An additional message to add to the end of the motd
#
# @param files_absent
#   Files to remove related to motd. Hash of parameters for file resource.
#
# @example
#   include profile_motd
class profile_motd (
  Hash $files_absent,
  Boolean $hide_enc,
  Array[String] $next_maintenance,
  String $next_maintenance_timezone,
  String $next_maintenance_details,
  String $notice,
) {
  ## PROCESS $next_maintenance AND DETERMINE $date_string
  $maintenance_begins = $next_maintenance[0]
  $maintenance_ends = $next_maintenance[1]
  if ($maintenance_begins != 'none' and ! empty($next_maintenance) ) {
    $start_array = split($next_maintenance[0], 'T')
    $start_date = $start_array[0]
    $start_time_array = split($start_array[1], ':')
    $start_time = "${start_time_array[0]}:${start_time_array[1]}"
    $end_array = split($next_maintenance[1], 'T')
    $end_date = $end_array[0]
    $end_time_array = split($end_array[1], ':')
    $end_time = "${end_time_array[0]}:${end_time_array[1]}"
    if ( $start_date == $end_date ) {
      $date_string = "${start_date} ${start_time}-${end_time} ${next_maintenance_timezone}"
    }
    else {
      $date_string = "${start_date} ${start_time} - ${end_date} ${end_time} ${next_maintenance_timezone}"
    }

    $config_parameters = {
      date    => $date_string,
      details => $next_maintenance_details,
    }
    file { '/etc/motd.d/90-maintenance':
      ensure  => 'file',
      content => epp("${module_name}/90-maintenance.epp", $config_parameters),
      group   => 'root',
      mode    => '0644',
      owner   => 'root',
    }
  } else {
    file { '/etc/motd.d/90-maintenance':
      ensure => 'absent',
    }
  }

  $hw_array = split($facts['dmi']['manufacturer'], Regexp['[\s,]'])
  $hardware = $hw_array[0]
  $memorysize_gb = ceiling($facts['memorysize_mb']/1024)
  #$cpu_array = split($facts['processors']['models']['0'], ' @ ')
  #$cpu_speed = $cpu_array[1]
  $cpu_speed = $facts['processors']['speed']

  file { '/etc/motd':
    ensure  => file,
    content => template('profile_motd/motd.erb'),
    mode    => '0644',
    owner   => '0',
    group   => '0',
  }

  ensure_resource( 'file', '/etc/motd.d', { 'ensure' => 'directory', 'mode' => '0755', })

  $motd_enc = "  Role: ${role}  Site: ${site}"
  if ! $hide_enc {
    $enc_motd_ensure = 'file'
    $enc_profile_ensure = 'absent'
  } else {
    $enc_motd_ensure = 'absent'
    $enc_profile_ensure = 'file'
  }
  file { '/etc/profile.d/puppet_enc_display.sh':
    ensure  => $enc_profile_ensure,
    content => template("${module_name}/puppet_enc_display.sh.erb"),
    mode    => '0644',
    owner   => '0',
    group   => '0',
  }
  file { '/etc/motd.d/20-puppet-enc':
    ensure  => $enc_motd_ensure,
    content => template("${module_name}/20-puppet-enc.erb"),
    group   => 'root',
    mode    => '0644',
    owner   => 'root',
    require => File['/etc/motd.d'],
  }

  if ( ! empty($notice) ) {
    $notice_ensure = 'file'
  } else {
    $notice_ensure = 'absent'
  }
  file { '/etc/motd.d/40-notice':
    ensure  => $notice_ensure,
    content => template("${module_name}/40-notice.erb"),
    group   => 'root',
    mode    => '0644',
    owner   => 'root',
    require => File['/etc/motd.d'],
  }

  if ( ($facts['os']['release']['major'] < '8' and $facts['os']['family'] == 'RedHat' ) or $facts['os']['family'] == 'Suse') {
    ## ADD /etc/motd.d/* SUPPORT TO RHEL7, SUSE, ETC
    File {
      mode   => '0644',
    }
    file { '/etc/profile.d/motd.csh':
      source => "puppet:///modules/${module_name}/etc/profile.d/motd.csh",
    }
    file { '/etc/profile.d/motd.sh':
      source => "puppet:///modules/${module_name}/etc/profile.d/motd.sh",
    }
  }

  $files_absent_defaults = {
    ensure => 'absent',
  }
  ensure_resources('file', $files_absent , $files_absent_defaults)
}
