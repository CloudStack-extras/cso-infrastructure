class jenkins { 

  yumrepo { jenkins: 
    baseurl => "http://pkg.jenkins-ci.org/redhat",
    enabled => 1,
    name => jenkins,
    gpgcheck => 0,
  }

  package { jenkins:
    ensure => present,
  }

  service { jenkins: 
    require => Package[jenkins],
    enable => true,
    hasstatus => true,
    ensure => true,
  }
  firewall { '8080 allow http-alt':
    proto       => 'tcp',
    dport       => '8080',
    action        => 'ACCEPT',
  }

}
