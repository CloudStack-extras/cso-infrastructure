class zenoss { 
	yumrepo { "zenoss":
		baseurl => "http://dev.zenoss.org/yum/stable/",
		name => "Zenoss",
		enabled => 1,
		gpgcheck => 0,
	}

	package { zenoss:
		ensure => "3.1.0-1031",
		require => Yumrepo[zenoss],
		}

	package { zenoss-core-zenpacks:
		ensure => "3.1.0-1031",
		require => Package[zenoss],
	}

	service { zenoss:
		ensure => running,
		hasstatus => true,
		enabled => true, 
		require => Package[zenoss],
	}

	service { mysqld: 
		ensure => running,
		hasstatus => true,
		enabled => true, 
		require => Package[zenoss],
	}
}

