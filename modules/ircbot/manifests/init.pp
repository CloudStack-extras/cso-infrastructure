class ircbot {

	package { supybot: ensure => latest}
	
	user { bot:
		ensure => present,
		name => "bot",
		}
}
