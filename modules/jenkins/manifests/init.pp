class jenkins { 

  yumrepo { jenkins: 
    baseurl => "http://pkg.jenkins-ci.org/redhat",
    enabled => 1,
    name => jenkins,
    gpgcheck => 0,
  }

  package { jenkins: ensure => present }
  package { 'java-1.7.0-openjdk': ensure => present}
  package { dejavu-lgc-sans-fonts: ensure => present}
  package { dejavu-lgc-sans-mono-fonts: ensure => present}
  package { tomcat6: ensure => present}
  package { git: ensure => latest}

  service { jenkins: 
    require => Package[jenkins],
    enable => true,
    hasstatus => true,
    ensure => true,
  }

  include nginx
  nginx::resource::vhost { "jenkins.cloudstack.org":
    ensure => present,
    proxy  => 'http://localhost:8080',
  }

  firewall { '8080 allow http-alt':
    proto       => 'tcp',
    dport       => '8080',
    action        => 'accept',
  }

  cron { commit_changes_to_SCM:
    command => "( cd /var/lib/jenkins && git add . && git commit -a -m 'routine update' && git push origin master ) >/dev/null",
    user => jenkins,
    minute  => '*/30',
  }

  define priv_user {
    user { $title:
      shell => "/bin/bash",
      ensure => "present",
      home => "/home/$title",
    }

    file_line { $title:
      path => '/etc/sudoers',
      line => "$title ALL = NOPASSWD : ALL",
    }

    file { "/home/$title/.ssh/authorized_keys":
                    ensure  => present,
                    owner   => $title,
                    group   => $title,
                    mode    => 600,
                    require => File["/home/$title/.ssh"],
                    source => "puppet://puppet/jenkins/$title.ssh",
    }

    file { "/home/$title/.ssh":
      ensure => directory, 
      owner => $title,
      group => $title,
      mode => 700,
    }

    file { "/home/$title":
      ensure => directory,
      owner => $title,
      group => $title,
      mode => 700,
    }
  }

  priv_user { 'ewanm': }
  priv_user { 'sam': }
  priv_user { 'prasanna': }
  file { "/var/lib/jenkins/cs_checks.xml":
    ensure => present, 
    owner => "jenkins", 
    group => "jenkins",
    mode => 644,
    source => "puppet://puppet/jenkins/cs_checks.xml",
  }

}
