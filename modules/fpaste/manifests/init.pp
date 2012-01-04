class fpaste {
  include postgres
  package { fpaste-server: ensure => present }
  package { mod_wsgi: ensure => present }
  package { python-psycopg2: ensure => present }
  
   file { "/usr/lib/python2.7/site-packages/fpaste_server/static/images/favicon.ico":
                owner   => root,
                group   => root,
                mode    => 644,
                source  => "puppet://puppet/fpaste/favicon.ico",
        }

file { "/usr/lib/python2.7/site-packages/fpaste_server/templates/fpaste_server/base.html":
  owner => root, 
  group => root,
  mode => 644,
  source => "puppet://puppet/fpaste/base.html"
  }

file { "/usr/lib/python2.7/site-packages/fpaste_server/templates/fpaste_server/header.html":
  owner => root,
  group => root,
  mode => 644,
  source => "puppet://puppet/fpaste/header.html"
  }

}
