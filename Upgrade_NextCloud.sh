#!/bin/bash
IPADD=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
NCVERSION=12.0.4
NCDB="ncdb"
NCUSER="ncuser"
NCUSERPASS="$(openssl rand -base64 12)"
NCDIR="/var/www/html/nextcloud"
NCDIRNEW="/var/www/html/nextcloud/"
clear
#----------------------------- User Input --------------------------------------------------
echo "Please enter root user MySQL password... (Password type prompt is hidden)"
read -s rootpasswd
mysql -uroot -p${rootpasswd} -e "show databases"
echo "Entering custom parameters..."
read -e -p "Desired database name for NextCloud... default is [$NCDB]: " -i "$NCDB" NCDB
read -e -p "Desired user name for NextCloud... default is [$NCUSER]: " -i "$NCUSER" NCUSER
read -e -p "Desired password for NextCloud user... default is [$NCUSERPASS]: " -i "$NCUSERPASS" NCUSERPASS
read -e -p "NextCloud location... default is [$NCDIR]: " -i "$NCDIR" NCDIR
# Backup sequence start
sudo mkdir /Backups
mysqldump -hlocalhost -uroot -p${rootpasswd} ${NCDB}| gzip > /Backups/NextCloud_db_Backup.zip
mysqldump -hlocalhost -uroot -p${rootpasswd} ${NCDB} > /Backups/nextcloud_Backup.sql
sudo tar -cpzvf /Backups/nextcloud-config.tar.gz $NCDIR/config/
sudo tar -cpvzf /Backups/nextcloud-data.tar.gz $NCDIR/data
sudo tar -cpvzf /Backups/nextcloud-apacheconfigs.tar.gz /etc/apache2/sites-available/nextcloud.conf
# Backup sequence finish
# Start Upgrade Sequence
mv $NCDIR $NCDIR-old
sudo mkdir /tmp
cd /tmp
wget https://download.nextcloud.com/server/releases/nextcloud-$NCVERSION.zip
echo "Finished."
echo "Unzipping NextCloud Binaries..."
unzip nextcloud-$NCVERSION.zip
sudo cp -r nextcloud/ /var/www/html/
sudo chown -R www-data:www-data $NCDIRNEW
sudo cp $NCDIR-old/config/config.php $NCDIRNEW/config/
sudo cp -r $NCDIR-old/data $NCDIRNEW/data
sudo systemctl restart apache2
cd /var/www/html/nextcloud
sudo -u www-data php occ upgrade
echo "Open up your web browser and navigate to URL: http://$IPADD/nextcloud." 
exit 0
