#!/bin/bash

######## Mount EFS
MOUNT_PATH="/var/www"
EFS_DNS_NAME=vars.efs_dns_name

[ $(grep -c $EFS_DNS_NAME /etc/fstab) -eq 0 ] && \
    echo "$EFS_DNS_NAME:/ $MOUNT_PATH nfs defaults 0 0" >> /etc/fstab && \
    mkdir -p $MOUNT_PATH && \
    mount $MOUNT_PATH

# Install packages
sudo apt -y update
sudo apt -y upgrade
#sudo apt install apache2 mariadb-server php-fpm php-mysql -y
sudo apt install apache2 php-fpm php-mysql -y
#sudo phpenmod mysqli
sudo service apache2 restart
systemctl start apache2
systemctl enable apache2
systemctl status apache2
#sudo apt install mariadb-server
#sudo systemctl enable --now mariadb
sudo apt install php-curl php-dom php-mbstring php-imagick php-zip php-gd -y
sudo apt  install -y php libapache2-mod-php
sudo apt install -y apache2-doc apache2-suexec-pristine 
sudo apt install -y apache2-suexec-custom www-browser
systemctl restart apache2

echo -e '<IfModule mod_setenvif.c>\n\tSetEnvIf X-Forwarded-Proto "^https$" HTTPS\n</IfModule>' > /etc/httpd/conf.d/xforwarded.conf
sed -i 's/post_max_size = 8M/post_max_size = 128M/g'  /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g'  /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 600/g'  /etc/php.ini
sed -i 's/; max_input_vars = 1000/max_input_vars = 2000/g'  /etc/php.ini
sed -i 's/max_input_time = 60/max_input_time = 300/g'  /etc/php.ini

systemctl enable --now httpd

#sudo ufw allow http
#sudo ufw allow 80/tcp
#sudo ufw allow https
#sudo ufw allow 443/tcp
#sudo ufw allow SSH
#sudo ufw allow 'Apache Full'
#sudo ufw enable

# Download Wordpress
WP_ROOT_DIR=$${MOUNT_PATH}/html
LOCK_FILE=$${MOUNT_PATH}/.wordpress.lock
EC2_LIST=$${MOUNT_PATH}/.ec2_list
WP_CONFIG_FILE=$${WP_ROOT_DIR}/wp-config.php

#Setting up wp-config.php
#mv wp-config.php $$MOUNT_PATH $$WP_CONFIG_FILE
#sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

SHORT_NAME=$(hostname -s)
echo "$${SHORT_NAME}" >> $${EC2_LIST}
FIRST_SERVER=$(head -1 $${EC2_LIST})

if [ ! -f $${LOCK_FILE} -a "$${SHORT_NAME}" == "$${FIRST_SERVER}" ]; then

# Create lock to avoid multiple attempts
	touch $${LOCK_FILE}

# ALB monitoring healthy during initialization


echo "OK" > $${WP_ROOT_DIR}/index.html

cd $${MOUNT_PATH}
wget http://wordpress.org/latest.tar.gz
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo rm -rf $${WP_ROOT_DIR}
sudo mv wordpress html
sudo mkdir $${WP_ROOT_DIR}/wp-content/uploads
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www
sudo find /var/www -type d -exec sudo chmod 2775 {} \;
sudo find /var/www -type f -exec sudo chmod 0664 {} \;
sudo rm -rf latest.tar.gz

sudo systemctl start httpd

###########################
# NEW TEST
###########################

# Download Latest WordPress archive from WP org
#wget https://wordpress.org/latest.tar.gz

#Extract the archive showing the progress
#pv latest.tar.gz | tar xzf - -C .
#tar -xzf latest.tar.gz

#Copy the content of WP Salts page
WPSalts=$(wget https://api.wordpress.org/secret-key/1.1/salt/ -q -O -)

#generate a random string; lower and upper case letters + numbers; maximun 9 characters
TablePrefx=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 9 | head -n 1)_

#Copy the current directory user name
WWUSER=$(stat -c '%U' ./)

#Add the following PHP code inside wp-config
cat <<EOF > wordpress/wp-config-sample.php
<?php

define('DB_NAME', '');
define('DB_USER', '');
define('DB_PASSWORD', '');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

/*WP Tweaks*/
#define( 'WP_SITEURL', '' );
#define( 'WP_HOME', '' );
#define( 'ALTERNATE_WP_CRON', true );
#define('DISABLE_WP_CRON', 'true');
#define('WP_CRON_LOCK_TIMEOUT', 900);
#define('AUTOSAVE_INTERVAL', 300);
#define( 'WP_MEMORY_LIMIT', '256M' );
#define( 'FS_CHMOD_DIR', ( 0755 & ~ umask() ) );
#define( 'FS_CHMOD_FILE', ( 0644 & ~ umask() ) );
#define( 'WP_ALLOW_REPAIR', true );
#define( 'FORCE_SSL_ADMIN', true );
#define( 'AUTOMATIC_UPDATER_DISABLED', true );
#define( 'WP_AUTO_UPDATE_CORE', false );

$WPSalts

\$table_prefix = '$TablePrefx';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOF

#Now that we are good, let's rename the wp-config sample
sudo mv wordpress/wp-config-sample.php wordpress/wp-config.php

#Move wordpress folder content in the current directory and remove the leftovers
#mv ./wordpress/* ./ && rm -rf latest.tar.gz && rm -rf ./wordpress

#Apply the definer user name to all the new freshly created wordpress files, plus the group (here the main on for Plesk Virtual Hosts)
chown -R ubuntu ./*

#Just to be sure, let's fix files and directories permissions
#find . -type f -exec chmod 644 {} \;
#find . -type d -exec chmod 755 {} \;

#Fancy message with colored background
#echo "$(tput setaf 7)$(tput setab 6)---|-WP READY TO ROCK-|---$(tput sgr 0)"

else
	echo "$(date) :: Lock is acquired by another server"  >> /var/log/user-data-status.txt
fi

sudo systemctl start httpd

#CRON job for backup:
crontab */5 * * * * cd /home/../*.com/public; /var/www; /usr/local/bin/wp; cron event run --due-now >/dev/null 2>&1

# Reboot
reboot