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
sudo docker info

ls -la /var/lib/pterodactyl/volumes/
#sudo nano /etc/systemd/system/wings.service
#sudo nano /etc/rc.local
#setsid /usr/local/bin/wings >/dev/null 2>&1 < /dev/null &

