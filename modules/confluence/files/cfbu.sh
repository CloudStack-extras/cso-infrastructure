#!/bin/bash
#
#This is to backup databases that we use all over creation.
#
mkdir -p /root/cfbu
cd /root/cfbu
find ./ -mtime +1 -name '*.bz2' -type f -exec rm '{}' \; #only delete previous confluence archives
tar -cjvf foo.bz2 /usr/local/confluence /root/cfbu/confluence-data
mv foo.bz2 confluence.`date +%d-%m-%y-%R`.$HOSTNAME.bz2
s3cmd --skip-existing --no-delete-removed sync * s3://backups.cloudstack.org/

