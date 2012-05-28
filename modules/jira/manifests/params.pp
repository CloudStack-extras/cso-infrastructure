class jira::params {
  # jira installation defaults
  $jira_installdir='/usr/local'
  $jira_dir='/usr/local/jira'
  $jira_datadir='/usr/local/jira-data'
  $jira_version='atlassian-jira-4.4.5-standalone'
  # mysql database connection info
  $jira_database='jira'
  $jira_user='jira'
  $jira_password='puppetrocks'

  # Package dependency:
  # http://jira.atlassian.com/display/DOC/Confluence+UNIX+and+X11+Dependencies

  $default_packages=$operatingsystem ? {
    'debian' => [ "libx11-6", "libx11-dev", "libxt6", "libxt6-dbg", "libxext6", "libxtst-dev", "libxtst6", "xlibs-dbg", "xlibs-dev", "mysql-server" ],
    'ubuntu' => [ "libice-dev", "libsm-dev", "libx11-dev", "libxext-dev", "libxp-dev", "libxt-dev", "libxtst-dev"],
    default => [ "libXp", "libXp-devel", "java-1.6.0-openjdk", ],
  }
}
