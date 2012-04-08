class mysql::server {
  package { 'mysql-server':
    ensure => present,
  }

  service { 'mysqld':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package[ 'mysql-server' ],
  }

## For backup
  package { 's3cmd' : ensure => present, }

  firewall { 'permit mysql in': 
    proto  => 'tcp',
    dport  => '3306',
    action => 'accept',
  }
}
