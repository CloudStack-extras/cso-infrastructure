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
  file { '/root/bu.sh':
    mode    => 700,
    owner   => 'root',
    group   => 'root',
    content => template('mysql/backup.erb'),
  }

  firewall { '888-permit_mysql_in': 
    proto  => 'tcp',
    dport  => '3306',
    action => 'accept',
  }
}
