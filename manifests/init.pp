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
  #$memorysize_gb = ceiling($facts['memory']['system']['total_bytes'] / 1024 / 1024 / 1024) + 1
  # Convert total bytes to decimal GB
  #$memorysize_gib = ceiling($facts['memory']['system']['total_bytes'] / 1000 / 1000 / 1000) + 1
  # Use a scaling factor of 1,050,000,000 bytes per GB to approximate how some hardware vendors and operating systems report memory size.
  # This value is chosen to provide a closer match to displayed memory sizes, which may differ from strict binary (1024^3) or decimal (1000^3) conversions.
  # The scaling factor 1050000000 is intentionally non-standard.
  # Standard conversions are 1024^3 (GiB) or 1000^3 (GB), but 1050000000 was chosen
  # to better match reported memory sizes on certain hardware, or as an empirical adjustment.
  $memorysize_scaled_gb = ceiling($facts['memory']['system']['total_bytes'] / 1050000000) + 1
  #$mem_gb = $memorysize_gb
  #$mem_gb = $memorysize_gib
  $mem_gb = $memorysize_scaled_gb
  # Determine rounding multiple based on thresholds
  # Thresholds chosen to provide readable memory size display for typical server classes:
  # - >768GB: Large enterprise servers, round to nearest 128GB for clarity
  # - >256GB: High-memory servers, round to nearest 64GB
  # - >128GB: Mid-range servers, round to nearest 32GB
  # - >64GB: Standard servers, round to nearest 16GB
  # - >32GB: Small servers, round to nearest 8GB
  # - >16GB: Workstations, round to nearest 4GB
  # - >1GB: Low-memory devices, round to nearest 2GB
  # - <=1GB: Embedded/special cases, round to nearest 1GB
  if $mem_gb > 768 {
    $multiple = 128
  } elsif $mem_gb > 256 {
    $multiple = 64
  } elsif $mem_gb > 128 {
    $multiple = 32
  } elsif $mem_gb > 64 {
    $multiple = 16
  } elsif $mem_gb > 32 {
    $multiple = 8
  } elsif $mem_gb > 16 {
    $multiple = 4
  } elsif $mem_gb > 1 {
    $multiple = 2
  } else {
    $multiple = 1
  }
  # Round to nearest multiple
  $display_memorysize_gb = round($mem_gb / $multiple) * $multiple

  #$cpu_speed = $facts['processors']['speed']
  $cpu_sockets = $facts['processors']['physicalcount']
  $cpu_cores = $facts['processors']['cores']
  #$cpu_count = $facts['processors']['count']
  $cpu_arch = $facts['processors']['isa']

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
