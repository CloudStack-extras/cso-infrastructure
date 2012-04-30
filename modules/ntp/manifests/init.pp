class ntp {

  package { 'ntpdate':
    ensure => latest
  }

  package { "ntp":
    ensure => latest,
  }

  service { "ntpd":
    ensure => running,
  }

  cron { 'ntpdate':
    ensure => absent,
    command => '/usr/sbin/ntpdate tick.redhat.com',
    user    => root,
    minute  => 24,
  }

}
