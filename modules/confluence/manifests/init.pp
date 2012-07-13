# Class: confluence
#
# Parameters:
#  ${confluence_installdir} installation target, default /usr/local
#  ${confluence_dir}        softlink which points to confluence files, default /usr/local/confluence
#  ${confluence_datadir}    confluence database directory, default /usr/local/confluence-data
#  ${confluence_version}    confluence software version, default match package name
#  ${confluence_database}   mysql database name
#  ${confluence_user}       mysql username
#  ${confluence_password}   mysql password
#  optional: (not implemented)
#  ${confluence_serverport} default 8000
#  ${confluence_connectorport} default 8080
#
# Actions:
#  This will install confluence to /usr/local/confluence/ -> ../confluence-{version}/
#  Packages: jdk1.6, libXp, mysql,
#  The initial mysql database will be populated with sensible defaults and mysql database.
#
# Requires:
#  module mysql
#
# Sample Usage:
#

class confluence {
  include mysql::server
  include confluence::params

  # confluence installation defaults
  if $params::confluence_installdir=='' {
    notice ("params::confluence_installdir unset, assuming /usr/local")
    $confluence_installdir='/usr/local'
  } else {
    $confluence_installdir=$params::confluence_installdir
  }
  if $params::confluence_dir=='' {
    notice ("params::confluence_dir unset, assuming /usr/local")
    $confluence_dir='/usr/local/confluence'
  } else {
    $confluence_dir=$params::confluence_dir
  }
  if $params::confluence_datadir=='' {
    notice ("params::confluence_datadir unset, assuming /usr/local")
    $confluence_datadir='/usr/local/confluence-data'
  } else {
    $confluence_datadir=$params::confluence_datadir
  }
  if $params::confluence_version=='' {
    notice ("params::confluence_version unset, assuming /usr/local")
    $confluence_version='atlassian-confluence-4.1.3'
  } else {
    $confluence_version=$params::confluence_version
  }

  # mysql configuration
  if $params::confluence_database=='' {
    notice ("params::confluence_database, assuming confluence")
    $confluence_database='confluence'
  } else {
    $confluence_database=$params::confluence_database
  }
  if $params::confluence_user=='' {
    notice ("params::confluence_user, assuming confluence")
    $confluence_user='confluence'
  } else {
    $confluence_user=$params::confluence_user
  }
  if $params::confluence_password=='' {
    notice ("params::confluence_password, assuming confluence")
    $confluence_password='puppetrocks'
  } else {
    $confluence_password=$params::confluence_password
  }


  package {
    $params::default_packages:
      ensure => present,
  }

  File { owner => '0', group => 'root', mode => '0644' }
  Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }


  file { "${confluence_installdir}":
    ensure => directory,
  }

  file { "confluence-init.properties":
    name => "${confluence_installdir}/${confluence_version}/confluence/WEB-INF/classes/confluence-init.properties",
    content => template ("confluence/confluence-init.properties.erb"),
  }

  file { "/etc/init.d/confluence":
    mode => '0755',
    content => template ("confluence/confluence.erb"),
  }

  service { "confluence":
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    require     => [ File[ "/etc/init.d/confluence" ,
                   "confluence-init.properties" 
                   ],
                   ],
  }


  service { "iptables": 
    ensure => stopped,
    hasstatus => true,
  } 

  file {'/root/cfbu.sh':
    source => 'puppet:///confluence/cfbu.sh',
    mode   => '0700',
    group  => 'root',
    owner  => 'root',
  }

  cron {'backup_confluence_dirs':
    command => '/root/cfbu.sh',
    user    => root,
    hour    => 04,
    minute  => 19,
  }
}
