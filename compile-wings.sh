#!/bin/bash

set -e

#############################################################################
#                                                                           #
# Project 'pterodactyl-installer' for wings                                 #
#                                                                           #
# Copyright (C) 2018 - 2021, Vilhelm Prytz, <vilhelm@prytznet.se>           #
#                                                                           #
#   This program is free software: you can redistribute it and/or modify    #
#   it under the terms of the GNU General Public License as published by    #
#   the Free Software Foundation, either version 3 of the License, or       #
#   (at your option) any later version.                                     #
#                                                                           #
#   This program is distributed in the hope that it will be useful,         #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
#   GNU General Public License for more details.                            #
#                                                                           #
#   You should have received a copy of the GNU General Public License       #
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.  #
#                                                                           #
# https://github.com/arvati/pterodactyl-installer/blob/master/LICENSE #
#                                                                           #
# This script is not associated with the official Pterodactyl Project.      #
# https://github.com/arvati/pterodactyl-installer                     #
#                                                                           #
#############################################################################

# versioning
GITHUB_SOURCE="master"
SCRIPT_RELEASE="canary"

#################################
######## General checks #########
#################################

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

#################################
########## Variables ############
#################################

# download URLs
WINGS_DL_URL="https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64"
GO_DL_URL="https://golang.org/dl/go1.16.6.linux-arm64.tar.gz"
GITHUB_BASE_URL="https://raw.githubusercontent.com/arvati/pterodactyl-installer/$GITHUB_SOURCE"

COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m'

INSTALL_MARIADB=false

# firewall
CONFIGURE_FIREWALL=false
CONFIGURE_UFW=false
CONFIGURE_FIREWALL_CMD=false

# SSL (Let's Encrypt)
CONFIGURE_LETSENCRYPT=false
FQDN=""
EMAIL=""

# regex for email input
regex="^(([A-Za-z0-9]+((\.|\-|\_|\+)?[A-Za-z0-9]?)*[A-Za-z0-9]+)|[A-Za-z0-9]+)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$"

#################################
####### Version checking ########
#################################

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

echo "* Retrieving release information.."
WINGS_VERSION="$(get_latest_release "pterodactyl/wings")"

####### Other library functions ########

valid_email() {
  [[ $1 =~ ${regex} ]]
}

#################################
####### Visual functions ########
#################################

print_error() {
  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

print_warning() {
  COLOR_YELLOW='\033[1;33m'
  COLOR_NC='\033[0m'
  echo ""
  echo -e "* ${COLOR_YELLOW}WARNING${COLOR_NC}: $1"
  echo ""
}

print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

required_input() {
  local __resultvar=$1
  local result=''

  while [ -z "$result" ]; do
    echo -n "* ${2}"
    read -r result

    [ -z "$result" ] && print_error "${3}"
  done

  eval "$__resultvar="'$result'""
}

#################################
####### OS check funtions #######
#################################

detect_distro() {
  if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$(echo "$ID" | awk '{print tolower($0)}')
    OS_VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si | awk '{print tolower($0)}')
    OS_VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
    OS_VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS="debian"
    OS_VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    OS="SuSE"
    OS_VER="?"
  elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    OS="Red Hat/CentOS"
    OS_VER="?"
  else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    OS_VER=$(uname -r)
  fi

  OS=$(echo "$OS" | awk '{print tolower($0)}')
  OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
}

check_os_comp() {
  SUPPORTED=false

  MACHINE_TYPE=$(uname -m)
  if [ "${MACHINE_TYPE}" != "aarch64" ]; then # check the architecture
    print_warning "Detected architecture $MACHINE_TYPE"
    print_warning "Using any other architecture than 64 bit (ARM) it is better use original bin file."

    echo -e -n "* Are you sure you want to proceed? (y/N):"
    read -r choice

    if [[ ! "$choice" =~ [Yy] ]]; then
      print_error "Installation aborted!"
      exit 1
    fi
  fi

  case "$OS" in
  ol)
    [ "$OS_VER_MAJOR" == "8" ] && SUPPORTED=true
    ;;
  *)
    SUPPORTED=false
    ;;
  esac

  # exit if not supported
  if [ "$SUPPORTED" == true ]; then
    echo "* $OS $OS_VER is supported."
  else
    echo "* $OS $OS_VER is not supported"
    print_error "Unsupported OS"
    exit 1
  fi

  # check virtualization
  echo -e "* Installing virt-what..."
  if [ "$OS" == "centos" ] || [ "$OS" == "ol" ]; then
    if [ "$OS_VER_MAJOR" == "8" ]; then
      dnf -y -q update

      # install virt-what
      dnf install -y -q virt-what
    fi
  else
    print_error "Invalid OS."
    exit 1
  fi

  virt_serv=$(virt-what)

  case "$virt_serv" in
  openvz | lxc)
    print_warning "Unsupported type of virtualization detected. Please consult with your hosting provider whether your server can run Docker or not. Proceed at your own risk."
    echo -e -n "* Are you sure you want to proceed? (y/N): "
    read -r CONFIRM_PROCEED
    if [[ ! "$CONFIRM_PROCEED" =~ [Yy] ]]; then
      print_error "Installation aborted!"
      exit 1
    fi
    ;;
  *)
    [ "$virt_serv" != "" ] && print_warning "Virtualization: $virt_serv detected."
    ;;
  esac

  if uname -r | grep -q "xxxx"; then
    print_error "Unsupported kernel detected."
    exit 1
  fi
}

############################
## INSTALLATION FUNCTIONS ##
############################

dnf_update() {
  dnf -y upgrade
}

enable_docker() {
  systemctl start docker
  systemctl enable docker
}

install_golang() {
  if [ "$OS" == "centos" ] || [ "$OS" == "ol" ]; then
    if [ "$OS_VER_MAJOR" == "8" ]; then
      dnf module -y install upx
      curl -o go.tar.gz $GO_DL_URL
      rm -rf /usr/local/go && tar -C /usr/local -xzf go.tar.gz
      echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/go.sh
    fi
  fi
  echo "* Golang has now been installed."
}

install_docker() {
  echo "* Installing docker .."
  if [ "$OS" == "centos" ] || [ "$OS" == "ol" ]; then
    if [ "$OS_VER_MAJOR" == "8" ]; then
      # Install dependencies for Docker
      dnf install -y dnf-utils device-mapper-persistent-data lvm2

      # Add repo to dnf
      dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

      # Install Docker
      dnf install -y docker-ce docker-ce-cli containerd.io --nobest
    fi

    enable_docker
  fi
  echo "* Docker has now been installed."
}

wings_compile() {
  echo "* Compiling Pterodactyl Wings .. "
  git clone https://github.com/pterodactyl/wings.git
  cd wings
  rm -rf build/wings_*
  /usr/local/go/bin/go mod download
  GIT_HEAD="$(git rev-parse HEAD | head -c8)"
  CGO_ENABLED=0 GOOS=linux GOARCH=arm64 /usr/local/go/bin/go build \
    -ldflags="-s -w -X github.com/pterodactyl/wings/system.Version=$GIT_HEAD" \
    -v \
    -trimpath \
    -o build/wings_linux_arm64 \
    wings.go
  upx --brute build/wings_*
  sudo cp build/wings_linux_arm64 /usr/local/bin/wings
  chmod u+x /usr/local/bin/wings
  mkdir -p /etc/pterodactyl
  echo "* Done."
}

systemd_file() {
  echo "* Installing systemd service.."
  curl -o /etc/systemd/system/wings.service $GITHUB_BASE_URL/configs/wings.service
  systemctl daemon-reload
  systemctl enable wings
  echo "* Installed systemd service!"
}

install_mariadb() {
  case "$OS" in
  centos | ol)
    [ "$OS_VER_MAJOR" == "8" ] && dnf install -y mariadb mariadb-server
    #dnf install -y mysql mysql-server
    #systemctl enable mysqld ; systemctl start mysqld
    ;;
  esac
  systemctl enable mariadb ; systemctl start mariadb
}

#################################
##### OS SPECIFIC FUNCTIONS #####
#################################

ask_letsencrypt() {
  if [ "$CONFIGURE_UFW" == false ] && [ "$CONFIGURE_FIREWALL_CMD" == false ]; then
    print_warning "Let's Encrypt requires port 80/443 to be opened! You have opted out of the automatic firewall configuration; use this at your own risk (if port 80/443 is closed, the script will fail)!"
  fi

  print_warning "You cannot use Let's Encrypt with your hostname as an IP address! It must be a FQDN (e.g. node.example.org)."

  echo -e -n "* Do you want to automatically configure HTTPS using Let's Encrypt? (y/N): "
  read -r CONFIRM_SSL

  if [[ "$CONFIRM_SSL" =~ [Yy] ]]; then
    CONFIGURE_LETSENCRYPT=true
  fi
}

firewall_firewalld() {
  echo -e "\n* Enabling firewall_cmd (firewalld)"
  echo "* Opening port 22 (SSH), 8080 (Daemon Port), 2022 (Daemon SFTP Port)"

  # Install
  [ "$OS_VER_MAJOR" == "8" ] && dnf -y -q install firewalld >/dev/null

  # Enable
  systemctl --now enable firewalld >/dev/null # Enable and start

  # Configure
  firewall-cmd --add-service=ssh --permanent -q                                           # Port 22
  firewall-cmd --add-port 8080/tcp --permanent -q                                         # Port 8080
  firewall-cmd --add-port 2022/tcp --permanent -q                                         # Port 2022
  [ "$CONFIGURE_LETSENCRYPT" == true ] && firewall-cmd --add-service=http --permanent -q  # Port 80
  [ "$CONFIGURE_LETSENCRYPT" == true ] && firewall-cmd --add-service=https --permanent -q # Port 443
  [ "$INSTALL_MARIADB" == true ] && firewall-cmd --add-service=mysql --permanent -q # Port 3306

  #firewall-cmd --permanent --zone=trusted --change-interface=pterodactyl0 -q
  firewall-cmd --zone=trusted --add-masquerade --permanent
  firewall-cmd --reload -q # Enable firewall

  echo "* Firewall-cmd installed"
  print_brake 70
}

letsencrypt() {
  FAILED=false

  # Install certbot
  if [ "$OS" == "centos" ] || [ "$OS" == "ol" ]; then
    [ "$OS_VER_MAJOR" == "8" ] && dnf -y install certbot python3-certbot-nginx socat
  else
    # exit
    print_error "OS not supported."
    exit 1
  fi

  # If user has nginx
  systemctl stop nginx || true

  # Obtain certificate
  certbot certonly --no-eff-email --email "$EMAIL" --standalone -d "$FQDN" || FAILED=true

  systemctl start nginx || true

  # Check if it succeded
  if [ ! -d "/etc/letsencrypt/live/$FQDN/" ] || [ "$FAILED" == true ]; then
    print_warning "The process of obtaining a Let's Encrypt certificate failed!"
    print_warning "You need to provide cloudflare Token, Account and Zone ID for acme.sh generate SSL certificate."
    echo -n "* Try with acme.sh? (y/N): "
    read -r ACMESH
    if [[ "$ACMESH" =~ [Yy] ]]; then
      required_input CF_Token "Cloudflare Token: " "Token cannot be empty"
      required_input CF_Account_ID "Cloudflare Account ID: " "Account cannot be empty"
      required_input CF_Zone_ID "Cloudflare Zone ID: " "Zone cannot be empty"
      FAILED=false
      mkdir -p "/etc/letsencrypt/live/$FQDN/"
      curl https://get.acme.sh | sh -s email="$EMAIL" 
      /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
      CF_Token="$CF_Token" CF_Account_ID="$CF_Account_ID" CF_Zone_ID="$CF_Zone_ID" /root/.acme.sh/acme.sh \
          --issue --dns dns_cf -d "$FQDN" --server letsencrypt \
          --key-file "/etc/letsencrypt/live/$FQDN/privkey.pem" \
          --cert-file "/etc/letsencrypt/live/$FQDN/cert.pem"  \
          --fullchain-file "/etc/letsencrypt/live/$FQDN/fullchain.pem" || FAILED=true
      [ ! -d "/etc/letsencrypt/live/$FQDN/privkey.pem" ] && FAILED=true
    else
      FAILED=true
    fi
  fi
}

####################
## MAIN FUNCTIONS ##
####################

perform_install() {
  echo "* Installing pterodactyl wings.."
  [ "$OS" == "centos" ] || [ "$OS" == "ol" ] && [ "$OS_VER_MAJOR" == "8" ] && dnf_update
  install_docker
  [ "$CONFIGURE_FIREWALL_CMD" == true ] && firewall_firewalld
  install_golang
  wings_compile
  systemd_file
  [ "$INSTALL_MARIADB" == true ] && install_mariadb
  [ "$CONFIGURE_LETSENCRYPT" == true ] && letsencrypt

  # return true if script has made it this far
  return 0
}

main() {
  # check if we can detect an already existing installation
  if [ -d "/etc/pterodactyl" ]; then
    print_warning "The script has detected that you already have Pterodactyl wings on your system! You cannot run the script multiple times, it will fail!"
    echo -e -n "* Are you sure you want to proceed? (y/N): "
    read -r CONFIRM_PROCEED
    if [[ ! "$CONFIRM_PROCEED" =~ [Yy] ]]; then
      print_error "Installation aborted!"
      exit 1
    fi
  fi

  # detect distro
  detect_distro

  print_brake 70
  echo "* Pterodactyl Wings installation script @ $SCRIPT_RELEASE"
  echo "*"
  echo "* Copyright (C) 2018 - 2021, Vilhelm Prytz, <vilhelm@prytznet.se>"
  echo "* https://github.com/arvati/pterodactyl-installer"
  echo "*"
  echo "* This script is not associated with the official Pterodactyl Project."
  echo "*"
  echo "* Running $OS version $OS_VER."
  echo "* Latest pterodactyl/wings is $WINGS_VERSION"
  print_brake 70

  # checks if the system is compatible with this installation script
  check_os_comp

  echo "* "
  echo "* The installer will install Docker, required dependencies for Wings"
  echo "* as well as Wings itself. But it's still required to create the node"
  echo "* on the panel and then place the configuration file on the node manually after"
  echo "* the installation has finished. Read more about this process on the"
  echo "* official documentation: $(hyperlink 'https://pterodactyl.io/wings/1.0/installing.html#configure')"
  echo "* "
  echo -e "* ${COLOR_RED}Note${COLOR_NC}: this script will not start Wings automatically (will install systemd service, not start it)."
  echo -e "* ${COLOR_RED}Note${COLOR_NC}: this script will not enable swap (for docker)."
  print_brake 42

  # Only ask if MySQL is not detected
  type mysql >/dev/null 2>&1 && ASK_MYSQL=false || ASK_MYSQL=true

  $ASK_MYSQL && echo -n "* Would you like to install MariaDB (MySQL) server on the daemon as well? (y/N): "
  $ASK_MYSQL && read -r CONFIRM_INSTALL_MARIADB
  $ASK_MYSQL && [[ "$CONFIRM_INSTALL_MARIADB" =~ [Yy] ]] && INSTALL_MARIADB=true

  # Firewall-cmd is available for CentOS
  if [ "$OS" == "centos" ] || [ "$OS" == "ol" ]; then
    echo -e -n "* Do you want to automatically configure firewall-cmd (firewall)? (y/N): "
    read -r CONFIRM_FIREWALL_CMD

    if [[ "$CONFIRM_FIREWALL_CMD" =~ [Yy] ]]; then
      CONFIGURE_FIREWALL_CMD=true
      CONFIGURE_FIREWALL=true
    fi
  fi

  ask_letsencrypt

  if [ "$CONFIGURE_LETSENCRYPT" == true ]; then
    while [ -z "$FQDN" ]; do
      echo -n "* Set the FQDN to use for Let's Encrypt (node.example.com): "
      read -r FQDN

      ASK=false

      [ -z "$FQDN" ] && print_error "FQDN cannot be empty"                                                            # check if FQDN is empty
      bash <(curl -s $GITHUB_BASE_URL/lib/verify-fqdn.sh) "$FQDN" "$OS" || ASK=true                                   # check if FQDN is valid
      [ -d "/etc/letsencrypt/live/$FQDN/privkey.pem" ] && print_error "A certificate with this FQDN already exists!" && ASK=true # check if cert exists

      [ "$ASK" == true ] && FQDN=""
      [ "$ASK" == true ] && echo -e -n "* Do you still want to automatically configure HTTPS using Let's Encrypt? (y/N): "
      [ "$ASK" == true ] && read -r CONFIRM_SSL

      if [[ ! "$CONFIRM_SSL" =~ [Yy] ]] && [ "$ASK" == true ]; then
        CONFIGURE_LETSENCRYPT=false
        FQDN="none"
      fi
    done
  fi

  if [ "$CONFIGURE_LETSENCRYPT" == true ]; then
    # set EMAIL
    while ! valid_email "$EMAIL"; do
      echo -n "* Enter email address for Let's Encrypt: "
      read -r EMAIL

      valid_email "$EMAIL" || print_error "Email cannot be empty or invalid"
    done
  fi

  echo -n "* Proceed with installation? (y/N): "

  read -r CONFIRM
  [[ "$CONFIRM" =~ [Yy] ]] && perform_install && return

  print_error "Installation aborted"
  exit 0
}

function goodbye {
  echo ""
  print_brake 70
  echo "* Wings installation completed"
  echo "*"
  echo "* To continue, you need to configure Wings to run with your panel"
  echo "* Please refer to the official guide, $(hyperlink 'https://pterodactyl.io/wings/1.0/installing.html#configure')"
  echo "* "
  echo "* You can either copy the configuration file from the panel manually to /etc/pterodactyl/config.yml"
  echo "* or, you can use the \"auto deploy\" button from the panel and simply paste the command in this terminal"
  echo "* "
  echo "* You can then start Wings manually to verify that it's working"
  echo "*"
  echo "* sudo wings"
  echo "*"
  echo "* Once you have verified that it is working, use CTRL+C and then start Wings as a service (runs in the background)"
  echo "*"
  echo "* systemctl start wings"
  echo "*"
  echo -e "* ${COLOR_RED}Note${COLOR_NC}: It is recommended to enable swap (for Docker, read more about it in official documentation)."
  [ "$CONFIGURE_FIREWALL" == false ] && echo -e "* ${COLOR_RED}Note${COLOR_NC}: If you haven't configured your firewall, ports 8080 and 2022 needs to be open."
  print_brake 70
  echo ""
}

# run script
main
goodbye