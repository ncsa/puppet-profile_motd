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
# @example
#   include profile_motd
class profile_motd (
  Boolean $hide_enc,                 # boolean to hide ENC data from motd, instead display for root via profile.d file
  Array[String] $next_maintenance,   # tuple with two date stamps, e.g., '2017-10-19T08:00:00'
  String $next_maintenance_timezone, # timezone used for next_maintenance
  String $next_maintenance_details,  # more details about next_maintenance
  String $notice,                    # additional message to add to the end of the motd
)
{

  ## PROCESS $next_maintenance AND DETERMINE $maintenance_message
  $maintenance_begins = $next_maintenance[0]
  $maintenance_ends = $next_maintenance[1]
  if ($maintenance_begins != 'none') {
    $start_array = split($next_maintenance[0], 'T')
    $start_date = $start_array[0]
    $start_time_array = split($start_array[1], ':')
    $start_time = "${start_time_array[0]}:${start_time_array[1]}"
    $end_array = split($next_maintenance[1], 'T')
    $end_date = $end_array[0]
    $end_time_array = split($end_array[1], ':')
    $end_time = "${end_time_array[0]}:${end_time_array[1]}"
    if ( $start_date == $end_date )
    {
      $date_string = "${start_date} ${start_time}-${end_time} ${next_maintenance_timezone}"
    }
    else
    {
      $date_string = "${start_date} ${start_time} - ${end_date} ${end_time} ${next_maintenance_timezone}"
    }
    $maintenance_message = "
Next scheduled maintenance: ${date_string} ${next_maintenance_details}"
  }
  else {
    $maintenance_message = ''
  }

  $notice_message = $notice ? {
    default   => '',
    String[1] => "\n${notice}",
  }

  $hw_array = split($::manufacturer, Regexp['[\s,]'])
  $hardware = $hw_array[0]
  $memorysize_gb = ceiling($::memorysize_mb/1024)
  $cpu_array = split($::processor0, ' @ ')
  $cpu_speed = $cpu_array[1]
  if ! $hide_enc {
    $motd_enc = "\n  Site: ${::site}  Role: ${::role}"
    $profile_ensure = 'absent'
  } else {
    $motd_enc = ''
    $profile_ensure = 'file'
  }

  file { '/etc/motd':
    ensure  => file,
    content => template('profile_motd/motd.erb'),
    mode    => '0644',
    owner   => '0',
    group   => '0',
  }

  file { '/etc/profile.d/puppet_enc_display.sh':
    ensure  => $profile_ensure,
    content => template('profile_motd/puppet_enc_display.sh.erb'),
    mode    => '0644',
    owner   => '0',
    group   => '0',
  }

  if ($facts['os']['release']['major'] < '8' and $facts['os']['family'] == 'RedHat') {
    ## ADD /etc/motd.d/* SUPPORT TO RHEL7, ETC
    File {
      mode   => '0644',
    }
    file { '/etc/profile.d/motd.csh':
      source => "puppet:///modules/${module_name}/etc/profile.d/motd.csh",
    }
    file { '/etc/profile.d/motd.sh':
      source => "puppet:///modules/${module_name}/etc/profile.d/motd.sh",
    }
    ensure_resource( 'file', '/etc/motd.d', { 'ensure' => 'directory', 'mode' => '0755', })
  }

}
