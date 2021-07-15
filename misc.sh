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