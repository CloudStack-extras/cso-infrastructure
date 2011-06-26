

node 'puppet' inherits basenode {
	include puppet::master
	include ircbot
}


