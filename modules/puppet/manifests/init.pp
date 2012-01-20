class puppet {

  package { puppet:
    ensure => present,
  }

  service { puppet:
    enabled => true,
    hasstatus => true, 
    require => Package[puppet],
  }

  file {"/etc/puppet/puppet.conf":
    source => "puppet://puppet/puppet/puppet.conf",
    owner => root,
    group => root,
    mode => 644,
    notify => Service[puppet],
  }
}

class puppet::master {
        package {puppet-server: ensure => present}

        service {puppetmaster:
                ensure => running,
                hasstatus => true,
                enable => true,
        }  

  cron { "checkpuppet": 
    command => "cd /etc/puppet && git pull origin master", 
    user => root, 
    minute  => '*/5',
  }
}
