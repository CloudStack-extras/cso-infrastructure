# /etc/puppet/modules/dhcpd/manifets/init.pp

class dhcpd {

        package { dhcp:
                name => $operatingsystem ? {
                        default => "dhcp",
                        },
                ensure => present,
        }

        service { dhcpd:
                name => $operatingsystem ? {
                        default => "dhcpd",
                        },
                ensure => running,
                enable => true,
                hasrestart => true,
                hasstatus => true,
                require => Package[dhcp],
        }
        file {
                "dhcpd.conf":
                        mode => 644, owner => root, group => root,
                        require => Package[dhcp],
                        ensure => present,
                        path => $operatingsystem ?{
                                default => "/etc/dhcpd.conf",
			notify => Service["dhcpd"],
                        },
			source => "puppet:///dhcpd/dhcpd.conf",
        }


}

