# Define: mysql::backup
#
# This module creates a script for backing up databases.
#
# Sample Usage:
#
#  mysql::backup { 'mydb':
#    user     => 'my_user',
#    password => 'password',
#    host     => $::hostname,
#    grant    => ['all']
#  }
#
define mysql::backup (
  $dbname = $name,
) {

  file { "/root/${name}-backup.sh":
    content => template ('mysql/backup.erb'),
    mode    => '0744',
  }

  cron { "${name}-backup":
    command => "/root/${name}-backup.sh",
    user    => root,
    minute  => 33,
  }
}
