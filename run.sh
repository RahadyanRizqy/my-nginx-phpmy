#!/bin/bash
#Tested on Ubuntu 22.04
#Tested on Debian 11
#Last test September 22th, 2023

# Create Bulk User and Their Database for Practicum Affair
# Index will be on /home/

apt update
apt install curl nginx mariadb-client mariadb-server iptables-persistent wget php php-zip php-intl php-curl php-mbstring php8.1 php8.1-fpm php8.1-mysql php8.1-common php8.1-cli php8.1-opcache php8.1-readline php8.1-mbstring php8.1-xml php8.1-gd php8.1-curl -y

systemctl enable php8.1-fpm
systemctl start php8.1-fpm

sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.1/fpm/php.ini
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.1/cli/php.ini

wget -O phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-english.tar.gz
tar -xvzf phpmyadmin.tar.gz
mv phpMyAdmin-5.2.1-english phpmyadmin
cp phpmyadmin/config.sample.inc.php phpmyadmin/config.inc.php
sed -i "s/\$cfg\['blowfish_secret'\] = '.*';/\$cfg['blowfish_secret'] = 'JBz?DX]#m\$Vy[m+M}o9jo?iMzpnQ9|U-';/" phpmyadmin/config.inc.php
mv phpmyadmin /var/www/html/phpmyadmin

mysql_secure_installation

iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 3306 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

service iptables restart

read -p "Mysql (ROOT) Username: " ROOTUSERNAME
read -p "Mysql (ROOT) Password: " ROOTPASSWORD
read -p "Common Password: " COMMON_PASSWORD
read -p "File List Input: " TXTFILE

DBPASSWORD=$COMMON_PASSWORD

# Read usernames from the list file and create users
while IFS= read -r USERNAME; do
  PASSWORD=$(openssl passwd -1 $COMMON_PASSWORD)  # Generate hashed password
  DBUSER=$USERNAME

  useradd -m -p $PASSWORD $USERNAME # Create user with home directory
  chsh -s /bin/bash $USERNAME
  chown -R $USERNAME:$USERNAME /home/$USERNAME
  find /home/$USERNAME -type d -exec chmod 755 {} \;
  find /home/$USERNAME -type f -exec chmod 644 {} \;
  cp -v index.html /home/$USERNAME;
  ln -s /home/$USERNAME /var/www/html

  mysql -u root -p$ROOTPASSWORD -e "CREATE DATABASE $DBUSER;"
  mysql -u root -p$ROOTPASSWORD -e "CREATE USER '$DBUSER'@'%' IDENTIFIED BY '$DBPASSWORD';"
  mysql -u root -p$ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $DBUSER.* TO '$DBUSER'@'%' WITH GRANT OPTION;"
  mysql -u root -p$ROOTPASSWORD -e "FLUSH PRIVILEGES;"

  echo "User $USERNAME and its database created with password: $COMMON_PASSWORD";
done < $TXTFILE # list of user from txt in same directory

cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default_orig
echo "" > /etc/nginx/sites-available/default
cat customnginx > /etc/nginx/sites-available/default
mv /var/www/html/index.nginx-debian.html /var/www/html/index-bak.html

mysql -u root -p$ROOTPASSWORD -e "CREATE USER '$ROOT$USERNAME'@'%' IDENTIFIED BY '$ROOTPASSWORD';"
mysql -u root -p$ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO '$ROOT$USERNAME'@'%' WITH GRANT OPTION;"
mysql -u root -p$ROOTPASSWORD -e "FLUSH PRIVILEGES;"

rm phpmyadmin.tar.gz
