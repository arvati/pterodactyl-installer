sudo firewall-cmd --list-all
sudo firewall-cmd --list-all-zones
ip add
sudo firewall-cmd --zone=public --permanent --list-ports

sudo firewall-cmd --zone=public --permanent --add-port=19132/udp
sudo firewall-cmd --zone=public --permanent --remove-port=19132/udp
sudo firewall-cmd --reload
sudo firewall-cmd --permanent --zone=public --add-source=172.17.0.1
sudo firewall-cmd --permanent --zone=public --add-source=172.18.0.1

sudo /usr/local/bin/wings
sudo chmod u+x /usr/local/bin/wings
sudo systemctl enable --now wings
sudo systemctl start wings
sudo systemctl status wings
sudo docker info

ls -la /var/lib/pterodactyl/volumes/
#sudo nano /etc/systemd/system/wings.service
#sudo nano /etc/rc.local
#setsid /usr/local/bin/wings >/dev/null 2>&1 < /dev/null &
cat /var/log/pterodactyl/wings.log

sudo su
wget https://golang.org/dl/go1.16.6.linux-arm64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.6.linux-arm64.tar.gz

type /usr/local/go/bin/go

/etc/profile.d/go.sh
export PATH=$PATH:/usr/local/go/bin

cd /root
git clone https://github.com/pterodactyl/wings.git
cd /root/wings
rm -rf build/wings_*
/usr/local/go/bin/go mod download
export GIT_HEAD=$(git rev-parse HEAD | head -c8)
#export GIT_HEAD=f4220816
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 /usr/local/go/bin/go build \
    -ldflags="-s -w -X github.com/pterodactyl/wings/system.Version=$GIT_HEAD" \
    -v \
    -trimpath \
    -o build/wings_linux_arm64 \
    wings.go
dnf install -y upx
upx --brute build/wings_*
build/wings_linux_arm64 version
sudo mv /usr/local/bin/wings /usr/local/bin/wings.old
sudo cp build/wings_linux_arm64 /usr/local/bin/wings
sudo chmod u+x /usr/local/bin/wings
sudo /usr/local/bin/wings version



sudo su
firewall-cmd --permanent --zone=public --add-source=172.18.0.1

systemctl stop mariadb
systemctl disable mariadb
systemctl enable mariadb
nano /etc/my.cnf.d/mariadb-server.cnf
systemctl restart mariadb


mysql -u root -p
USE mysql;
CREATE USER 'pterodactyluser'@'152.67.44.250' IDENTIFIED BY 'password';
ALTER USER 'pterodactyluser'@'127.0.0.1' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'pterodactyluser'@'152.67.44.250' WITH GRANT OPTION;
CREATE DATABASE s14_authme;
CREATE USER 'u14_YIS0cQ7N5e'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON s14_authme.* TO 'u14_YIS0cQ7N5e'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

#export VER="5.1.1"
curl -o phpMyAdmin-5.1.1-all-languages.zip https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-all-languages.zip
sudo unzip -q phpMyAdmin*.zip
sudo mv phpMyAdmin-5.1.1-all-languages /usr/share/phpMyAdmin
sudo mv /usr/share/nginx/html/phpmyadmin /usr/share/phpMyAdmin
sudo cp /usr/share/phpMyAdmin/config.sample.inc.php  /usr/share/phpMyAdmin/config.inc.php
sudo nano /usr/share/phpMyAdmin/config.inc.php

$cfg['blowfish_secret'] = '$2a$07$H6V9J74bK5S5qez6CRXt7OviIqRlFwJiniEFAaBsGXoz8MCukudia'; 
$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';

sudo mkdir /var/lib/phpmyadmin
sudo mkdir /var/lib/phpmyadmin/tmp
sudo chown -R nginx:nginx /var/lib/phpmyadmin

sudo mysql < /usr/share/phpMyAdmin/sql/create_tables.sql -u root -p

sudo systemctl restart php-fpm
sudo systemctl restart nginx

sudo nano /etc/nginx/conf.d/phpMyAdmin.conf
sudo chown root:nginx /var/lib/php/session

server {
   listen 80;
   server_name pma.itzgeek.local;
   root /usr/share/phpMyAdmin;

   location / {
      index index.php;
   }

## Images and static content is treated different
   location ~* ^.+.(jpg|jpeg|gif|css|png|js|ico|xml)$ {
      access_log off;
      expires 30d;
   }

   location ~ /\.ht {
      deny all;
   }

   location ~ /(libraries|setup/frames|setup/libs) {
      deny all;
      return 404;
   }

   location ~ \.php$ {
         try_files $uri =404;
         fastcgi_intercept_errors on;
         include        fastcgi_params;
         fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
         fastcgi_pass unix:/run/php-fpm/www.sock;
     }
}

sudo dnf install php php-common php-process php-xmlrpc php-xml php-soap php-snmp php-recode php-bcmath php-cli php-dba php-dbg php-mbstring php-odbc php-pecl-apcu-devel php-pecl-zip php-pgsql php-pecl-apcu php-pear php-pdo php-opcache php-devel php-embedded php-enchant php-gd php-fpm php-gmp php-intl php-ldap php-json php-mysqlnd php-pdo php-gd php-mbstring zip unzip tar wget
sudo dnf -y install nginx nginx-all-modules

sudo semanage fcontext -a -t httpd_sys_content_t "/usr/share/phpMyAdmin(/.*)?"
sudo restorecon -Rv /usr/share/phpMyAdmin

sudo nano /etc/php-fpm.d/www.confuser = nginx

; RPM: Keep a group allowed to write in log dir.
group = nginx

;listen = 127.0.0.1:9000
listen = /run/php-fpm/www.sock

listen.owner = nginx
listen.group = nginx
listen.mode = 0660

