#rpmbuilder - build tools mvn, java, createrepo, yum

class rpmbuilder {
  include maven

  $linux_packages = ['wget', 'curl', 'openssh-clients', 'mysql-server', 'gcc', 'glibc-devel']
  $java_packages = ['jakarta-commons-collections', 'tomcat6', 'java-1.6.0-openjdk-devel'] 

  package { $linux_packages:
    ensure => installed,
  }
  package { $java_packages: 
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
