class base {
        package { screen: ensure => latest }
        package { vim-enhanced: ensure => latest}

firewall { '000 allow packets with valid state':
    state       => ['RELATED', 'ESTABLISHED'],
    action        => 'ACCEPT',
  }
  firewall { '001 allow icmp':
    proto       => 'icmp',
    action        => 'ACCEPT',
  }
  firewall { '002 allow all to lo interface':
    iniface       => 'lo',
    action        => 'ACCEPT',
  }
  firewall { '100 allow ssh':
    proto       => 'tcp',
    dport       => '22',
    action        => 'ACCEPT',
  }
  firewall { '999 drop everything else':
    action        => 'REJECT',
  }

  resources { 'firewall':
    purge => false,
  }


}
