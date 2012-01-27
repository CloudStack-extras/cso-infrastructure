class jenkins::builder {

  package { ant: ensure => present }
  package { log4j: ensure => present }
  package { cglib: ensure => present }
  package { genisoimage: ensure => present } 
  package { checkstyle: ensure => present } 
}
