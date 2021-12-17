#!/bin/bash

#---------------------------------------------------------------
# Script to set up an AWS Ubuntu instance for serving the MDI web page.
# Create a new instance, then run this script from an SSH command prompt.
#---------------------------------------------------------------

#---------------------------------------------------------------
# use sudo initially to install resources and configure server as root
#---------------------------------------------------------------

# update system
echo 
echo "updating operating system"
sudo apt-get update
sudo apt-get upgrade -y

# install miscellaneous tools
echo 
echo "install miscellaneous tools"
sudo apt-get install -y \
  git \
  build-essential \
  tree \
  nano \
  apache2-utils \
  dos2unix \
  nfs-common \
  make \
  binutils

# install Docker
echo 
echo "install Docker engine"
sudo apt-get install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io

# install docker-compose
echo 
echo "install Docker compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# allow user ubuntu to control docker without sudo
echo 
echo "add ubuntu to docker group"
sudo usermod -aG docker ubuntu

# set server groups
echo 
echo "create mdi-edit group"
sudo groupadd mdi-edit
sudo usermod -a -G mdi-edit ubuntu

# set server paths and permissions
echo 
echo "initialize /srv file tree (root)"
cd /srv
sudo mkdir data # for external data bind-mounted into running instances
sudo mkdir mdi  # for mdi server support
sudo chown -R ubuntu   data mdi
sudo chgrp -R mdi-edit data mdi
sudo chmod -R ug+rwx   data mdi

#---------------------------------------------------------------
# continue as user ubuntu (i.e., not sudo) to populate /srv
#---------------------------------------------------------------
echo 
echo "initialize /srv file tree (ubuntu)"
mkdir mdi/config
mkdir mdi/logs
mkdir mdi/resource-scripts

# clone the MDI server code repository
echo 
echo "clone mdi-web-server.git"
cd /srv/mdi
git clone https://github.com/MiDataInt/mdi-web-server.git

# copy web server configuration templates to final location outside of the repo
echo 
echo "copy server config templates"
cp mdi-web-server/lib/inst/*.sh  /srv/mdi/config
cp mdi-web-server/lib/inst/*.yml /srv/mdi/config

# add the server executable script to PATH
echo 
echo "initialize server target and add to PATH"
cp mdi-web-server/lib/inst/server /srv/mdi
chmod ug+x /srv/mdi/server
echo -e "\n\nexport PATH=/srv/mdi:\$PATH\n" >> ~/.bashrc

# validate and report success
echo
echo "installation summary"
docker --version
docker-compose --version
echo
tree /srv
echo