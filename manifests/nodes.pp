

node 'puppet' inherits basenode {
	include puppet::master
	include ircbot
}


node 'demo4-cp.sjc.vmops.com' inherits basenode {
	include zenoss
	include ssh
}

node 'nalley2.cloud.com' inherits basenode {
	include cloudstack::nfs-common
	include ssh
}
