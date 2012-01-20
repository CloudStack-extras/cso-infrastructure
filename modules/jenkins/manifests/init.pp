class jenkins { 

  yumrepo { jenkins: 
    baseurl => "http://pkg.jenkins-ci.org/redhat/jenkins.repo",
    enabled => true,
    name => jenkins,
    gpgcheck => 0,
  }

  package { jenkins:
    requires => Yumrepo[jenkins],
    ensure => present,
  }

  service { jenkins: 
    require => Package[jenkins],
    enable => true,
    hasstatus => true,
  }

}
