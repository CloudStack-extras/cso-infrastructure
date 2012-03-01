class ntp {
  
  package { ntpdate: ensure => latest }
 
  cron { ntpdate: 
    command => "/usr/sbin/ntpdate tick.redhat.com",
    user => root,
    hour => *, 
    minute => 24,
  }

}
