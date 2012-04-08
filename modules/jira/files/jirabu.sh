#!/bin/bash
#
#This is to backup databases that we use all over creation.
#
mkdir -p /usr/local/jira/data/attachments/bu
cd /usr/local/jira/data/attachments/bu
find ./ -mtime +1 -type f -exec rm '{}' \;
tar -cjvf foo.bz2 /usr/local/jira/data/attachments/CS
mv foo.bz2 jira.`date +%d-%m-%y-%R`.$HOSTNAME.bz2
s3cmd --skip-existing --no-delete-removed sync * s3://backups.cloudstack.org/

