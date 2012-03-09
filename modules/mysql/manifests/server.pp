class mysql::server {
  package { "mysql-server":
    ensure => present,
  }

  service { "mysqld":
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => Package[ "mysql-server" ],
  }

## For backup
  package { "s3cmd" : ensure => present, }

}
