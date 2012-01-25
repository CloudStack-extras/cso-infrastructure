class jenkins::builder {

  package { ant: ensure => present }
  package { log4j: ensure => present }
  package { cglib: ensure => present }
  package { genisoimg: ensure => present } 
  package { checkstyle: ensure => present } 
}
