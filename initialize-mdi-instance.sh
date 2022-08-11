#!/bin/bash

#---------------------------------------------------------------
# Script to set up an AWS Ubuntu instance for serving the MDI web page.
# Create a new EC2 instance, then run this script from an SSH command prompt.
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

# install Docker, now including docker-compose via plugin
echo 
echo "install Docker engine"
sudo apt-get install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
sudo mkdir -p /etc/apt/keyrings  
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

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
git clone https://github.com/MiDataInt/mdi-manager.git
cp mdi-manager/inst/config/*.yml /srv/mdi/config
rm -rf mdi-manager

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
docker compose version
echo
tree /srv
echo
