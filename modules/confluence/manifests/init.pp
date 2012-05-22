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
    $confluence_dir='/usr/local/confluence-4.2.3'
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
    $confluence_version='atlassian-confluence-4.2.3'
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

  # not usable for now
  $confluence_license='AAABOg0ODAoPeNpdkF1rwjAUhu/zKwK7rrRxm0MITJsOumkdtk6Q3cT06AJpKvmQ+e8Xawuy23PyPu9z8rCFGr97hUmCk8l0PJk+veCUVZjESYwYWGHkyclW07TVB+VBC8BJjDcWjP2e4tJx48DghRSgLaDCN3swq0O3pwGRGuDXPOMO6BUaxZOIEBRwjgtX8AYoa/1RcYvn3ikwSISmUdjJM1BnPAxvsyWXitb77tUrdyFiJdcj0TYoO3PluyJ64CqIdJDeqrqcoCsqq9m6ytZI3eZfwfGaICiQtQPNw3XZ70may6Cb9LodbjguVd6Go4u2BktjtDJHrqW9tc8GLVRmRSCMYzImqARzBpMzOv/YPUa7t9VzNFuyPFrnmy3qLcN2kbMh0Q/vbLxWspEOavTpjfjhFv7/6R+ObpoJMCwCFBzjnNnfcOIaq2R1pEmcu1oTeowbAhRwm81wsBaZ+0ZYWLZIw0liPuuIdw==X02fn'


  package {
    $params::default_packages:
      ensure => present,
  }

  File { owner => '0', group => 'root', mode => '0644' }
  Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }


  file { "${confluence_installdir}":
    ensure => directory,
  }

  exec { "extract_confluence":
    command => "gtar -xf /tmp/atlassian-confluence-4.2.3.tar.gz -C ${confluence_installdir}",
    require => File [ "${confluence_installdir}" ],
    subscribe => Exec [ "dl_cf" ],
    creates => "${confluence_installdir}/${confluence_version}",
  }


  exec {"dl_cf":
    command => "wget http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-4.2.3.tar.gz",
    cwd => "/tmp",
    creates => "/tmp/atlassian-confluence-4.2.3.tar.gz",
  }

  file { "${confluence_dir}":
    ensure => "${confluence_installdir}/${confluence_version}",
    require => Exec [ "extract_confluence" ];
  }

  # confluence package have wrong userid 1418
#  exec { "chown_confluence":
#    command => "chown -R root ${confluence_installdir}/${confluence_version}",

#    subscribe => Exec [ "extract_confluence" ],
#    refreshonly => true,
#  }

  file { "confluence-init.properties":
    name => "${confluence_installdir}/${confluence_version}/confluence/WEB-INF/classes/confluence-init.properties",
    content => template ("confluence/confluence-init.properties.erb"),
    subscribe => Exec [ "extract_confluence" ],
  }

  # cannot autogen hash from license key, pending confluence API.
  #file { "confluence.cfg.xml":
  #  name => "${confluence_datadir}/confluence.cfg.xml",
  #  content => template ("confluence.cfg.xml.erb"),
  #  noop => true,
#  }

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
                     Exec[ "create_${confluence_database}" ]
                   ],
  }


  service { "iptables": 
    ensure => stopped,
    hasstatus => true,
  } 

  file {"/tmp/confluence.sql":
    source => "puppet:///modules/confluence/confluence.sql",
  }



  # mysql database creation and table setup (onetime)
  exec { "create_${confluence_database}":
    command => "mysql -e \"create database ${confluence_database}; \
               grant all on ${confluence_database}.* to '${confluence_user}'@'localhost' \
               identified by '${confluence_password}';\"; \ ", 
        

######       mysql ${confluence_database} < /tmp/confluence.sql",
   unless => "/usr/bin/mysql ${confluence_database}",
   require => [ Service[ "mysqld" ],
                 File[ "/tmp/confluence.sql" ] ],
  }

  file {"/etc/httpd/conf.d/confluence.conf":
    source => "puppet:///confluence/confluence.conf",
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

