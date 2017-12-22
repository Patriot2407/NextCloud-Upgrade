#!/bin/bash
IPADD=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
NCVERSION=12.0.4
NCDB="ncdb"
NCUSER="ncuser"
NCUSERPASS="$(openssl rand -base64 12)"
clear
#----------------------------- User Input --------------------------------------------------
echo "Please enter root user MySQL password... (Password type prompt is hidden)"
read -s rootpasswd
mysql -uroot -p${rootpasswd} -e "show databases"
echo "Entering custom parameters..."
read -e -p "Desired database name for NextCloud... default is [$NCDB]: " -i "$NCDB" NCDB
read -e -p "Desired user name for NextCloud... default is [$NCUSER]: " -i "$NCUSER" NCUSER
read -e -p "Desired password for NextCloud user... default is [$NCUSERPASS]: " -i "$NCUSERPASS" NCUSERPASS
# Backup sequence start
sudo mkdir /Backups
mysqldump -hlocalhost -uroot -p${rootpasswd} ${NCDB}| gzip > /Backups/NextCloud_db_Backup.zip
mysqldump -hlocalhost -uroot -p${rootpasswd} ${NCDB} > /Backups/nextcloud_Backup.sql
sudo tar -cpzvf /Backups/nextcloud-config.tar.gz /var/www/nextcloud/config/
sudo tar -cpvzf /Backups/nextcloud-data.tar.gz /var/www/nextcloud/data
# Backup sequence finish

echo "Open up your web browser and navigate to URL: http://$IPADD/nextcloud." 
exit 0
