# /etc/puppet/modules/httpd/manifests/init.pp
#
class httpd {

##############################################################3
## Packages
##############################################################


        package { httpd: ensure => present }

##############################################################
## Services
#############################################################

        service { httpd:
                name => $operatingsystem ? {
                        default => "httpd",
                        },
                ensure => running,
                enable => true,
                hasstatus => true,
                require => Package[httpd],
        }


##############################################################
## Files
##############################################################
#


        file { "/etc/httpd/conf/httpd.conf":
                owner   => root,
                group   => root,
                mode    => 644,
                source  => "puppet://puppet/httpd/httpd.conf",
        }

##############################################################
# IPTables
##############################################################
        iptables { "http":
                proto   => "tcp",
                dport   => "80",
                jump    => "ACCEPT",
        }
        iptables { "https":
                proto   => "tcp",
                dport   => "443",
                jump    => "ACCEPT",
        }



}

