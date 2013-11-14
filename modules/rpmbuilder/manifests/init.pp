#rpmbuilder - build tools mvn, java, createrepo, yum

class rpmbuilder {
  include maven

  $linux_packages = ['wget', 'curl', 'git', 'openssh-clients', 'mysql-server', 'gcc', 'glibc-devel', 'createrepo', 'rpm-build']
  $java_packages = ['jakarta-commons-collections', 'tomcat6', 'java-1.6.0-openjdk-devel', 'ws-commons-util'] 
  $python_packages = ['MySQL-python', 'python-pip']

  group { 'jenkins':
    ensure => present,
  }

  user { 'jenkins':
    ensure => present,
    groups => ['jenkins'],
    home   => '/var/lib/jenkins',
  }

  file { '/var/lib/jenkins':
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => 755,
  }

  package { $linux_packages:
    ensure => installed,
  }
  package { $java_packages: 
    ensure => installed,
  }
  package { $python_packages: 
    ensure => installed,
  }
  #Needed for systemvm.iso
  package { 'genisoimage':
    ensure => installed,
  }

  case $operatingsystem {
    centos,redhat : {
    }
    fedora : {
    }
  }

  service { 'mysqld':
    ensure => running,
  }
}
