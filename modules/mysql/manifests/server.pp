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
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mysql/backup.erb'),
  }

  cron { 'dbbackup':
    command  => '/root/bu.sh',
    user     => root,
    minute   => 13,
    requires => File['/root/bu.sh'],
  }

  firewall { '888-permit_mysql_in': 
    proto  => 'tcp',
    dport  => '3306',
    action => 'accept',
  }
}
