class ircbot {

	package { supybot: ensure => latest}
	
	user { bot:
		ensure => present,
		name => "bot",
		}
	exec { "/usr/bin/supybot /home/bot/cloudbot.conf":
		unless => "lsof | grep cloudbot.conf",
		user => "bot",
	} 

	file { "/home/bot":
		ensure => directory,
		owner => "bot",
		group => "bot",
		require => User[bot],
	}

	file { "/home/bot/backup":
		ensure => directory,
		owner => "bot",
		group => "bot",
		require => File["/home/bot"],
	}

        file { "/home/bot/conf":
                ensure => directory,
                owner => "bot",
                group => "bot",
                require => File["/home/bot"],
        }

        file { "/home/bot/data":
                ensure => directory,
                owner => "bot",
                group => "bot",
                require => File["/home/bot"],
        }

        file { "/home/bot/logs":
                ensure => directory,
                owner => "bot",
                group => "bot",
                require => File["/home/bot"],
        }

        file { "/home/bot/plugins":
                ensure => directory,
                owner => "bot",
                group => "bot",
                require => File["/home/bot"],
        }

        file { "/home/bot/tmp":
                ensure => directory,
                owner => "bot",
                group => "bot",
                require => File["/home/bot"],
        }



}
