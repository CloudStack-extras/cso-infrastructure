class confluence::redhat {
  include confluence::params

  # Installing Sun Java because open jdk is not supported:
  # http://confluence.atlassian.com/display/DOC/System+Requirements
  case $architecture {
    'x64': { $confluence_java = 'jdk-6u21-linux-x64-rpm.bin' }
    'i386': { $confluence_java = 'jdk-6u21-linux-i586-rpm.bin' }
  }

  File { owner => root, group => root, mode => 644 }

  file { "/tmp/${confluence_java}" :
    mode => 755,
    source => "puppet:///modules/confluence/${confuence_java}",
  }

  Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }

  exec { "install_java" :
    command => "/tmp/${confluence_java}",
    unless => "rpm -q --quiet jdk-1.6.0_21-fcs",
    require => File [ "/tmp/${confluence_java}" ];
  }
}
