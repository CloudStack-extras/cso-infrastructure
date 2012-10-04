class jenkins { 

  yumrepo { jenkins: 
    baseurl => "http://pkg.jenkins-ci.org/redhat",
    enabled => 1,
    name => jenkins,
    gpgcheck => 0,
  }

  package { jenkins: ensure => '1.484-1.1 }
  package { 'java-1.7.0-openjdk': ensure => present}
  package { 'java-1.7.0-openjdk-devel': ensure => present}
  package { dejavu-lgc-sans-fonts: ensure => present}
  package { dejavu-lgc-sans-mono-fonts: ensure => present}
  package { tomcat6: ensure => present}
  package { git: ensure => latest}
  package { publican: ensure => latest}
  package { mysql-connector-java: ensure => present}
  package { maven: ensure => present} 
  package { wget: ensure => present} 
  service { jenkins: 
    require => Package[jenkins],
    enable => true,
    hasstatus => true,
    ensure => true,
  }

  include nginx
  nginx::resource::vhost { "jenkins.cloudstack.org":
    ensure => present,
    proxy  => 'http://localhost:8080',
  }

  firewall { '80 allow http':
    proto       => 'tcp',
    dport       => '80',
    action        => 'accept',
  }

  firewall { '8080 allow http-alt':
    ensure => absent,
    proto       => 'tcp',
    dport       => '8080',
    action        => 'accept',
  }

  cron { commit_changes_to_SCM:
    command => "( cd /var/lib/jenkins && git add . && git commit -a -m 'routine update' && git push -q origin master ) >/dev/null",
    user => jenkins,
    minute  => '*/30',
  }

  users::priv_user { 'edison': }
  users::priv_user { 'prasanna': }

  file { "/var/lib/jenkins/cs_checks.xml":
    ensure => present, 
    owner => "jenkins", 
    group => "jenkins",
    mode => 644,
    source => "puppet://puppet/jenkins/cs_checks.xml",
  }

}
