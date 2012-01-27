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

  firewall { '8080 allow http-alt':
    proto       => 'tcp',
    dport       => '8080',
    action        => 'accept',
  }

  cron { commit_changes_to_SCM:
    command => "cd /var/lib/jenkins && git add . && git commit -a -m 'routine update' && git push origin master",
    user => jenkins,
    minute  => '*/30',
  }

  user { sam:
    shell => "/bin/bash",
    ensure => "present",
    home => "/home/sam",
    }

  file_line { 'sam_sudo_rule':
    path => '/etc/sudoers',
    line => 'sam ALL = NOPASSWD : ALL',
  }
  file { "/home/sam/.ssh/authorized_keys":
                    ensure  => present,
                    owner   => sam,
                    group   => sam,
                    mode    => 600,
                    require => File["/home/sam/.ssh"],
                    source => "puppet://puppet/jenkins/sam.ssh",
            }

  file { "/home/sam/.ssh":
    ensure => directory, 
    owner => 'sam',
    group => 'sam',
    mode => 700,
  }

  file { "/home/sam":
   ensure => directory,
   owner => 'sam',
   group => 'sam',
   mode => 700,
  }
}
