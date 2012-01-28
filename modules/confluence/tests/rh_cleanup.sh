#!/bin/bash
# cleanup everything to repeat testing.

#set -e
set -u

# confluence 
/usr/local/confluence-3.3-std/bin/shutdown.sh

yes | rm /etc/init.d/confluence
rm -rf /usr/local/confluence
rm -rf /usr/local/confluence-3.3-std/
rm -rf /usr/local/confluence-data

# mysql
mysql -e "drop user 'confluence'@'localhost';"
yes "Yes" | mysqladmin drop confluence
service mysqld stop
#yes | yum remove mysql-server
#yes | yum remove mysql
