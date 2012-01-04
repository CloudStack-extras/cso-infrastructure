

node 'puppet' {
	include puppet::master
	include ircbot
}


node 'demo4-cp.sjc.vmops.com' inherits basenode {
	include zenoss
	include ssh
}

node 'nalley2.cloud.com' inherits basenode {
	include cloudstack::nfs-common
	include cloudstack::mgmt
	include ssh
}

node 'mgmt1.demo.cloudstack.org' inherits basenode { 

node 'domu-12-31-39-05-44-b3.compute-1.internal' inherits basenode {
	include httpd
	include fpaste
}


}
