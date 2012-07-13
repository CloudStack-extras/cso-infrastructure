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
                  source => "puppet://puppet/users/$title.ssh",
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
