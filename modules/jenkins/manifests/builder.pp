class jenkins::builder {

  package { ant: ensure => present }
  package { log4j: ensure => present }
  package { cglib: ensure => present }
  package { mkisofs: ensure => present } 
}
