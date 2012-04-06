

node 'puppet' {
	include puppet::master
	include ircbot
        include ntp
        
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
}
node 'domu-12-31-39-05-44-b3.compute-1.internal' {
	include httpd
	include fpaste
        include ntp
}

node 'domu-12-31-39-15-22-2d.compute-1.internal' {
  include puppet
  include jenkins
  include jenkins::builder
  include ntp
}

node 'domu-12-31-39-09-e2-77.compute-1.internal' {
  include mysql::server
  include confluence
  include ntp

}

node 'ip-10-72-113-173.ec2.internal' {
  include jira
  include ntp
}

