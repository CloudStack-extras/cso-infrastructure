# Class: jira
#
# Parameters:
#  ${jira_installdir} installation target, default /usr/local
#  ${jira_dir}        softlink which points to jira files, default /usr/local/jira
#  ${jira_datadir}    jira database directory, default /usr/local/jira-data
#  ${jira_version}    jira software version, default match package name
#  ${jira_database}   mysql database name
#  ${jira_user}       mysql username
#  ${jira_password}   mysql password
#  optional: (not implemented)
#  ${jira_serverport} default 8000
#  ${jira_connectorport} default 8080
#
# Actions:
#  This will install jira to /usr/local/jira/ -> ../jira-{version}/
#  Packages: jdk1.6, libXp, mysql,
#  The initial mysql database will be populated with sensible defaults and mysql database.
#
# Requires:
#  module mysql
#
# Sample Usage:
#

class jira {
  include jira::params
#  include httpd::proxy
# commenting that out b/c we moved to nginx


  # jira installation defaults
  if $params::jira_installdir=='' {
    notice ('params::jira_installdir unset, assuming /usr/local')
    $jira_installdir='/usr/local'
  } else {
    $jira_installdir=$params::jira_installdir
  }
  if $params::jira_dir=='' {
    notice ('params::jira_dir unset, assuming /usr/local')
    $jira_dir='/usr/local/jira'
  } else {
    $jira_dir=$params::jira_dir
  }
  if $params::jira_datadir=='' {
    notice ('params::jira_datadir unset, assuming /usr/local')
    $jira_datadir='/usr/local/jira-data'
  } else {
    $jira_datadir=$params::jira_datadir
  }
  if $params::jira_version=='' {
    notice ('params::jira_version unset, assuming /usr/local')
    $jira_version='atlassian-jira-4.4.4-standalone'
  } else {
    $jira_version=$params::jira_version
  }

  # mysql configuration
  if $params::jira_database=='' {
    notice ('params::jira_database, assuming jira')
    $jira_database='jira'
  } else {
    $jira_database=$params::jira_database
  }
  if $params::jira_user=='' {
    notice ('params::jira_user, assuming jira')
    $jira_user='jira'
  } else {
    $jira_user=$params::jira_user
  }
  if $params::jira_password=='' {
    notice ('params::jira_password, assuming jira')
    $jira_password='puppetrocks'
  } else {
    $jira_password=$params::jira_password
  }



  package {
    $params::default_packages:
      ensure => present,
  }

  File { owner => '0', group => 'root', mode => '0644' }
  Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin' }


  file { 'jira-application.properties':
    ensure => present,
    name   => "${jira_installdir}/${jira_version}/atlassian-jira/WEB-INF/classes/jira-application.properties",
    source => 'puppet://puppet/jira/jira-application.properties',
  }


  file { '/etc/init.d/jira':
    mode    => '0755',
    content => template ('jira/jira.erb'),
  }


  service { 'jira':
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    require     => File[ '/etc/init.d/jira' ,
      'jira-application.properties'
      ],
  }


  service { 'iptables':
    ensure    => stopped,
    hasstatus => true,
  }

  file {'/root/jirabu.sh':
    source => 'puppet:///jira/jirabu.sh',
    mode   => '0700',
    owner  => root,
    group  => root,
  }

  cron {jirabu : 
    command => '/root/jirabu.sh',
    user    => root,
    hour    => 05,
    minute  => 32,
  }
  #mysql::backup{ jira }

  users::priv_user { 'pradeep': }
  users::priv_user { 'prayees': }
}
