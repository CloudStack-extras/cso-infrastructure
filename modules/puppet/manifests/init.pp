class puppet {
	package {puppet: ensure => present}

	service {puppetd:
		ensure => running, 
		hasstatus => true,
		enable => true,
		}
}

class puppet::master {
	package {puppet-server: ensure => present}

}

