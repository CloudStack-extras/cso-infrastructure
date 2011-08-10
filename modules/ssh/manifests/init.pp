class ssh { 

	package { openssh-server: ensure => latest}
	package { openssh: ensure => latest}

	service { sshd:
		ensure => running,
		enable => true,
		hasstatus => true, 
		require => Package[openssh-server],
		subscribe => File["sshd-conf"],
	}

	file { sshd-conf:
		path => "/etc/ssh/sshd_config",
		mode => 600,
		owner => root,
		group => root,
		source => "puppet://puppet/ssh/sshd_config",
	}

	file { banner:
		path => "/etc/ssh/banner",
		mode => 444,
		owner => root,
		group => root,
		source => "puppet://puppet/ssh/banner",
	}

        file { authorized_keys:
                path => "/root/.ssh/authorized_keys",
                mode => 600,
                owner => root,
                group => root,
                selrange => s0,
                selrole => object_r,
                seltype => home_ssh_t,
                seluser => system_u,
                source => [ "puppet://puppet/ssh/authorized_keys.$hostname", "puppet://puppet/ssh/authorized_keys", ],
                require => File["/root/.ssh"]
        }

        file { "/root/.ssh":
                ensure => directory,
                mode => 700,
                owner => root,
                group => root,
                selrange => s0,
                seltype => home_ssh_t,
                selrole => object_r,
                seluser => system_u,
        }

        iptables { "permit inbound ssh":
                proto   => "tcp",
                dport   => "22",
                jump    => "ACCEPT",
        }

}

