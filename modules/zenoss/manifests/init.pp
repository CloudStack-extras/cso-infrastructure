class zenoss { 
	yumrepo { "zenoss":
		baseurl => "http://dev.zenoss.org/yum/stable/",
		name => "Zenoss",
		enabled => 1,
		gpgcheck => 0,
	}

	package { zenoss:
		ensure => "3.1.0",
		require => Yumrepo[zenoss],
		}

	package { zenoss-core-zenpacks:
		ensure => "3.1.0",
		require => Yumrepo[zenoss],
	}

}

