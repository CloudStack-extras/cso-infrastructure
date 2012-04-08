#!/bin/bash
#
#This is to backup databases that we use all over creation.
#
mkdir -p /root/cfbu
cd /root/cfbu
find ./ -mtime +1 -type f -exec rm '{}' \;
tar -cjvf foo.bz2 /usr/local/confluence /usr/local/confluence-data
mv foo.bz2 confluence.`date +%d-%m-%y-%R`.$HOSTNAME.bz2
s3cmd --skip-existing --no-delete-removed sync * s3://backups.cloudstack.org/

