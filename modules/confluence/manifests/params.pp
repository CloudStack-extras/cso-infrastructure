class confluence::params {
  # confluence installation defaults
  $confluence_installdir='/usr/local'
  $confluence_dir='/usr/local/confluence'
  $confluence_datadir='/root/cfbu/confluence-data'
  $confluence_version='atlassian-confluence-4.2.3'
  # mysql database connection info
  $confluence_database='confluence'
  $confluence_user='confluence'
  $confluence_password='puppetrocks'

  # Package dependency:
  # http://confluence.atlassian.com/display/DOC/Confluence+UNIX+and+X11+Dependencies

  $default_packages=$operatingsystem ? {
    'debian' => [ "libx11-6", "libx11-dev", "libxt6", "libxt6-dbg", "libxext6", "libxtst-dev", "libxtst6", "xlibs-dbg", "xlibs-dev", "mysql-server" ],
    'ubuntu' => [ "libice-dev", "libsm-dev", "libx11-dev", "libxext-dev", "libxp-dev", "libxt-dev", "libxtst-dev"],
    default => [ "libXp", "libXp-devel", "java-1.6.0-openjdk", ],
  }
}
