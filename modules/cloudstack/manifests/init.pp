class cloudstack {
		include cloudstack::no_selinux

        case $operatingsystem {
                centos,redhat : {
                        yumrepo{"Cloudstack":
                                baseurl => "http://yumrepo/repositories/rhel/$operatingsystemrelease/stable/oss/",
                                name => "CloudStack",
                                enabled => 1,
                                gpgcheck => 0,
                        }
                }
                fedora : {
                        yumrepo{"Cloudstack":
                                baseurl => "http://yumrepo/repositories/fedora/$operatingsystemrelease/stable-2.2/oss/",
                                name => "CloudStack",
                                enabled => 1,
                                gpgcheck => 0,
                	}

        	}

	}

######### DEFINITIONS ####################

	$cs_mgmt_server = "192.168.203.177"
	$dns1 = "192.168.203.1"
	$dns2 = "8.8.8.8"
	$cs_agent_netmask = "255.255.255.0"
	


}
class cloudstack::nfs-common {
#this subclass provides NFS for primary and secondary storage on a single machine.
#this is not production quality - but useful for a POC/demo/dev/test environment. 
#you will either want to significantly alter or use your own nfs class

	include cloudstack

	package {nfs-utils: ensure => present}

	service {nfs:
		ensure => running,
		enabled => true,
		hasstatus => true,
		require => Service[rpcbind],
		require => File["/primary"],
	}

	service {rpcbind: 
		ensure => running,
		enabled => true,
		hasstatus => true,
	}
	file {"/primary":
		ensure => directory,
		mode => 777,
	}
	file {"/secondary":
		ensure => directory,
		mode => 777,
		require => File["/primary"],
	}
	file {"/etc/sysconfig/nfs":
		source => "puppet://puppet/cloudstack/nfs",
		notify => Service[nfs],
	}

	file {"/etc/exports":
		source => "puppet://puppet/cloudstack/exports",
		notify => Service[nfs],
	}

	iptables {"udp111":
		proto => "udp",
		port => "111",
		jump => "ACCEPT",
	}

	iptables {"tcp111":
		proto => "tcp",
		port  => "111",
		jump => "ACCEPT",
	}

        iptables {"tcp2049":
                proto => "tcp",
                port  => "2049",
                jump => "ACCEPT",
        }		

        iptables {"tcp32803":
                proto => "tcp",
                port  => "32803",
                jump => "ACCEPT",
        }

        iptables {"udp32769":
                proto => "udp",
                port  => "32769",
                jump => "ACCEPT",
        }

        iptables {"tcp892":
                proto => "tcp",
                port  => "892",
                jump => "ACCEPT",
        }

        iptables {"udp892":
                proto => "udp",
                port  => "892",
                jump => "ACCEPT",
        }

        iptables {"tcp875":
                proto => "tcp",
                port  => "875",
                jump => "ACCEPT",
        }

        iptables {"udp875":
                proto => "udp",
                port  => "875",
                jump => "ACCEPT",
        }

        iptables {"tcp662":
                proto => "tcp",
                port  => "662",
                jump => "ACCEPT",
        }

        iptables {"udp662":
                proto => "udp",
                port  => "662",
                jump => "ACCEPT",
        }
	
}


class cloudstack::kvmagent {
	include cloudstack 
	package {cloud-agent : ensure => present, require => Yumrepo[CloudStack], }

	exec { "cloud-setup-agent":
		creates => "/var/log/cloud/setupAgent.log",
		requires => Package[cloud-agent],
		requires => Package[NetworkManager],
		requires => File["/etc/sudoers"],
		requires => File["/etc/cloud/agent/agent.properties"],
		requires => File["/etc/sysconfig/network-scripts/ifcfg-eth0"],
		requires => File["/etc/hosts"],
		requires => File["/etc/sysconfig/network"],
		requires => File["/etc/resolv.conf"],
		requires => Service["network"],


	}

	file { "/etc/sudoers":
		source =>  "puppet://puppet/cloudstack/sudoers",
	}

	file { "/etc/cloud/agent/agent.properties": 
		ensure => present,
		requires => Package[cloud-agent],
		content =>  template("cloudstack/agent.properties")
	}

######## AGENT NETWORKING SECTION SEE NOTES BEFORE END OF NETWORKING SECTION ############
	
	file { "/etc/sysconfig/network-scripts/ifcfg-eth0":
		content => template("cloudstack/ifcfg-eth0"),
	}


	service { network: 
		ensure => running, 
		enabed => true,
		hasstatus => true, ## Is that really true?
		requires => Package[NetworkManager],
		requires => File["/etc/sysconfig/network-scripts/ifcfg-eth0"],
	}
	
	package { NetworkManager:
		ensure => absent,
	}

	file { "/etc/sysconfig/network":
		content => template("cloudstack/network"),
	}

	file { "/etc/hosts":  ## Note this file pulls from facter - you may need to adjust to define this externally
		content => template("cloudstack/hosts"),
	} 

	file { "/etc/resolv.conf":
		content => template("cloudstack/resolv.conf"),
	}

### NOTES: This assumes a single NIC (eth0) will be used for CloudStack and ensures that the 
### config file is correct syntactically and in place
### If you wish to use more than a single NIC you will need to edit both the agent.properties
### file and add additional ifcfg-ethX files to this configuration. 
### 

######### END AGENT NETWORKING ##############################################################

########### TODO - get an actual /etc/sudoers in place
##########check and see if management actually looks for sudoers as well, 
######### if so place sudoers in the cloudstack class. 
########## Also need to create a agent.properties stanza, and likely need to define
########## IP address or name for management server - and do agent.properties as a template. 
############ Need to do something that will take care of IP configuration
############ Need to do something that will take care of KVM - make sure module is loaded - need to define what tests cloud-setup-agent actually runs to test for KVM and ensure that we do those tests as well, and rectify if needed (do a reboot?? )
### Need to handle hostname addition as well - and probably a def gw and ensuring that DNS is set since
### we are so backwards as to not use DHCP


### IP Address thoughts:
### Use a template based on /etc/sysconfig/ifcfg-ethX
### By default only specify eth0, with liberal commenting about what to do in the event of needing to change our simple configuration (e.g. edit agent.properites, add additional network config, etc. 
### Require network to be enabled
### Require NetworkManager be disabled (Is it installed by default, do we need to do a case?, perhaps we 'ensure absent') 
### Make sure we cycle network after deploying a ifcfg. 
### Do we handle creation of cloud-br0? I am thinking not, seems like there's a lot of magic there. For now, lets stay away from that. 

}

class cloudstack::mgmt {
	include cloudstack


	package {cloud-client : ensure => present, require => Yumrepo[CloudStack], }

	exec { "cloud-setup-management":
		creates => "/var/log/cloud/setupManagement.log",
		requires => Package[cloud-client],
		requires => File["/var/lib/mysql/cloud"],
		} 
########## Requires the iptables module from: http://github.com/camptocamp/puppet-iptables/ 

	iptables { "http":
		proto => "tcp",
		dport => "80",
		jump => "ACCEPT",
	}

	iptables { "http-alt":
		proto => "tcp",
		dport => "8080",
		jump => "ACCEPT",
		}

	iptables { "port-8096":      ###### find out what this port does in cloudstack
		proto => "tcp",
		dport => "8096",
		jump => "ACCEPT",
		}

	iptables { "port-8250":     ############ Think this is for cpvm, but check for certain. 
		proto => "tcp",
		dport => "8250",
		jump => "ACCEPT",
		}

	iptables { "port-9090":    ####################### find out what this does in cloudstack
		proto => "tcp",
		dport => "9090",
		jump => "ACCEPT",
		}


#################### MYSQL SECTION - can likely be removed if you are using puppet in production and use your own mysql module #########
# wondering if i should do this as a separate subclass

	package {mysql-server : ensure => present }

	service {mysqld:
                name => $operatingsystem? {
                        default => "mysqld",
			ubuntu => "mysql",
                        },
                ensure => running, 
                enable => true, 
                hasstatus => true, 
                require => Package[mysql-server],
        }
	file {"/etc/my.cnf":
		source => "puppet://puppet/cloudstack/my.cnf",
		notify => Service[mysqld],
	}

	exec {"cloud-setup-databases cloud:dbpassword@localhost --deploy-as=root":
		creates => "/var/lib/mysql/cloud",
		requires => Package[cloud-client],
		requires => Package[mysql-server],
	}

	file { "/var/lib/mysql/cloud":
		ensure => present,
	}
################## END MYSQL SECTION ###################################################################################################
		


}

class cloudstack::no_selinux {
	file { "/etc/selinux/config":
		source => "puppet://puppet/cloudstack/config",
	}
	exec { "/usr/sbin/setenforce 0":
		onlyif => "/usr/sbin/getenforce | grep Enforcing",
	}
}
