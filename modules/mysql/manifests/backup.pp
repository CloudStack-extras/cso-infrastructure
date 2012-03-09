#class mysql::backup { 
#
#  package { s3cmd: ensure => latest } 
#
#}

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

  file { "/root/${dbname}-backup.sh":
    content => template ("mysql/backup.erb"),
    mode => '0744',
  }

  cron { ${dbname}-backup: 
    command => "/root/${dbname}-backup.sh",
    user => root,
    minute => 33,
  } 
}  
