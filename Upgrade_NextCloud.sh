#!/bin/bash
IPADD=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
NCVERSION=14.0.6
NCDIR="/var/www/html/nextcloud"
NCDIRNEW="/var/www/html/nextcloud/"
clear
#----------------------------- User Input --------------------------------------------------
echo "Please enter root user MySQL password... (Password type prompt is hidden)"
read -s rootpasswd
mysql -uroot -p${rootpasswd} -e "show databases"
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
# sudo -u www-data php occ upgrade
# Upgrade sequence finish
echo "Open up your web browser and navigate to URL: http://$IPADD/nextcloud." 
echo "
Sometimes, Nextcloud can get stuck in a upgrade if the web based upgrade process is used. This is usually due to the process taking too long and encountering a PHP time-out. Stop the upgrade process this way:

sudo -u www-data php occ maintenance:mode --off
Then start the manual process:

sudo -u www-data php occ upgrade
If this does not work properly, try the repair function:

sudo -u www-data php occ maintenance:repair
"
exit 0
