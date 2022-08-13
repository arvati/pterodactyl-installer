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


curl -o go.tar.gz https://go.dev/dl/go1.18.4.linux-arm64.tar.gz

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



cat /etc/nginx/conf.d/pterodactyl.conf
rm -rf /etc/nginx/conf.d/pterodactyl.conf
curl -o /etc/nginx/conf.d/pterodactyl.conf https://raw.githubusercontent.com/arvati/pterodactyl-installer/master/configs/nginx_ssl.conf
sed -i -e "s@<domain>@DOMAIN@g" /etc/nginx/conf.d/pterodactyl.conf
sed -i -e "s@<php_socket>@/var/run/php-fpm/pterodactyl.sock@g" /etc/nginx/conf.d/pterodactyl.conf

ls /var/www/pterodactyl -la
cat /var/www/pterodactyl/.env

cat /etc/pterodactyl/config.yml
/usr/local/bin/wings
systemctl start wings
sudo systemctl start docker

sudo systemctl start nginx
sudo systemctl start pteroq

firewall-cmd --get-active-zones
systemctl stop wings && docker network rm pterodactyl_nw && systemctl start wings
/usr/local/bin/wings

sudo firewall-cmd --get-zone-of-interface=pterodactyl0
sudo firewall-cmd --zone=trusted --remove-interface=pterodactyl0
sudo firewall-cmd --zone=trusted --remove-interface=pterodactyl0 --permanent
sudo firewall-cmd --reload -q
systemctl start wings

firewall-cmd --permanent --zone=trusted --change-interface=pterodactyl0 -q
firewall-cmd --zone=trusted --add-masquerade --permanent -q
firewall-cmd --reload -q # Enable firewall

# Increase size ORACLE INSTANCE BOOT DISK
df -hT | grep mapper
sudo pvs
lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                  8:0    0  100G  0 disk
├─sda1               8:1    0  100M  0 part /boot/efi
├─sda2               8:2    0    2G  0 part /boot
└─sda3               8:3    0 44.5G  0 part
  ├─ocivolume-root 252:0    0 29.5G  0 lvm  /
  └─ocivolume-oled 252:1    0   15G  0 lvm  /var/oled

sudo pvresize /dev/sda3
sudo dnf -y install cloud-utils-growpart
sudo growpart /dev/sda 3
sudo pvs
sudo vgs
sudo lvextend -r -l +100%FREE /dev/ocivolume/root
lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                  8:0    0  100G  0 disk
├─sda1               8:1    0  100M  0 part /boot/efi
├─sda2               8:2    0    2G  0 part /boot
└─sda3               8:3    0 97.9G  0 part
  ├─ocivolume-root 252:0    0 82.9G  0 lvm  /
  └─ocivolume-oled 252:1    0   15G  0 lvm  /var/oled



curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_arm64










cat /etc/pterodactyl/config.yml
debug: false
app_name: Pterodactyl
uuid: 
token_id: 
token: 
api:
  host: 0.0.0.0
  port: 8080
  ssl:
    enabled: true
    cert: /etc/letsencrypt/live/server..com/fullchain.pem
    key: /etc/letsencrypt/live/server..com/privkey.pem
  disable_remote_download: false
  upload_limit: 100
system:
  root_directory: /var/lib/pterodactyl
  log_directory: /var/log/pterodactyl
  data: /var/lib/pterodactyl/volumes
  archive_directory: /var/lib/pterodactyl/archives
  backup_directory: /var/lib/pterodactyl/backups
  tmp_directory: /tmp/pterodactyl
  username: pterodactyl
  timezone: GMT
  user:
    uid: 984
    gid: 980
  disk_check_interval: 150
  activity_send_interval: 60
  activity_send_count: 100
  check_permissions_on_boot: true
  enable_log_rotate: true
  websocket_log_count: 150
  sftp:
    bind_address: 0.0.0.0
    bind_port: 2022
    read_only: false
  crash_detection:
    enabled: true
    detect_clean_exit_as_crash: true
    timeout: 60
  backups:
    write_limit: 0
  transfers:
    download_limit: 0
docker:
  network:
    interface: 172.18.0.1
    dns:
    - 1.1.1.1
    - 1.0.0.1
    name: pterodactyl_nw
    ispn: false
    driver: bridge
    network_mode: pterodactyl_nw
    is_internal: false
    enable_icc: true
    network_mtu: 1500
    interfaces:
      v4:
        subnet: 172.18.0.0/16
        gateway: 172.18.0.1
      v6:
        subnet: fdba:17c8:6c94::/64
        gateway: fdba:17c8:6c94::1011
  domainname: ""
  registries: {}
  tmpfs_size: 100
  container_pid_limit: 512
  installer_limits:
    memory: 1024
    cpu: 100
  overhead:
    override: false
    default_multiplier: 1.05
    multipliers: {}
  use_performant_inspect: true
throttles:
  enabled: true
  lines: 2000
  line_reset_interval: 100
remote: https://host.vanaware.com
remote_query:
  timeout: 30
  boot_servers_per_page: 50
allowed_mounts: []
allowed_origins: []
allow_cors_private_network: false

