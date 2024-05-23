apt update

apt install curl git nginx mariadb-client mariadb-server iptables-persistent wget php php-zip php-intl php-curl php-mbstring php8.1 php8.1-fpm php8.1-mysql php8.1-common php8.1-cli php8.1-opcache php8.1-readline php8.1-mbstring php8.1-xml php8.1-gd php8.1-curl nginx-extras -y

systemctl enable php8.1-fpm
systemctl start php8.1-fpm

sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.1/fpm/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.1/cli/php.ini

wget -O phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-english.tar.gz

tar -xvzf phpmyadmin.tar.gz
mv phpMyAdmin-5.2.1-english phpmyadmin
cp phpmyadmin/config.sample.inc.php phpmyadmin/config.inc.php
sed -i "s/\$cfg\['blowfish_secret'\] = '.*';/\$cfg['blowfish_secret'] = 'JBz?DX]#m\$Vy[m+M}o9jo?iMzpnQ9|U-';/" phpmyadmin/config.inc.php
mv phpmyadmin /var/www/pma
chmod 777 -R /var/www/

mysql_secure_installation

read -p "(ROOT) Password: " ROOTPASSWORD
read -p "Create Mysql Admin Username: " MYADMINUSERNAME
read -p "Create Mysql Admin Password: " MYADMINPASSWORD

mysql -u root -p$ROOTPASSWORD -e "CREATE USER '$MYADMINUSERNAME'@'%' IDENTIFIED BY 'MYADMINPASSWORD';"
mysql -u root -p$ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO '$MYADMINUSERNAME'@'%';"
mysql -u root -p$ROOTPASSWORD -e "FLUSH PRIVILEGES;"

sed -i "s/bind-address            = 127.0.0.1/bind-address = 0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf

cp -v /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

curl https://raw.githubusercontent.com/RahadyanRizqy/nginx-phpmy/main/nginx-phpmy > /etc/nginx/sites-available/default

service mariadb restart
service nginx restart
