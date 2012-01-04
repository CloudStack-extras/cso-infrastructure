class postgres { 
  package { postgresql-server: ensure => present }

  service { postgresql: 
    ensure => running,
    enable => true,
    hasstatus => true,
    require => Package[postgresql-server],
  }
}
