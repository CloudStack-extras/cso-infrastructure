class jenkins::builder {

  package { ant: ensure => present }
  package { log4j: ensure => present }
  package { cglib: ensure => present }
  package { genisoimage: ensure => present } 
  package { checkstyle: ensure => present } 
  package { mysql-server: ensure => present}
  package { maven: ensure => present } 
  package { gcc: ensure => present }
  package { glibc-devel: ensure => present }
  package { MySQL-python: ensure => present } 
  service { mysqld:
    name => $operatingsystem ? {
      default => "mysqld",
       },
      ensure => running,
      enable => true,
      hasstatus => true,
      require => Package[mysql-server],
  }


}
