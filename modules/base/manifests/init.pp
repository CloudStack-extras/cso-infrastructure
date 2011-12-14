class base {
        package { screen: ensure => latest }
        package { vim-enhanced: ensure => latest}

firewall { '000 allow packets with valid state':
    state       => ['RELATED', 'ESTABLISHED'],
    jump        => 'ACCEPT',
  }
  firewall { '001 allow icmp':
    proto       => 'icmp',
    jump        => 'ACCEPT',
  }
  firewall { '002 allow all to lo interface':
    iniface       => 'lo',
    jump        => 'ACCEPT',
  }
  firewall { '100 allow ssh':
    proto       => 'tcp',
    dport       => '22',
    jump        => 'ACCEPT',
  }
  firewall { '999 drop everything else':
    jump        => 'DENY',
  }

  resources { 'firewall':
    purge => false,
  }


}
