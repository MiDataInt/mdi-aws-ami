#!/bin/bash

#---------------------------------------------------------------
# Script to set up an AWS Ubuntu instance for serving the MDI web page.
# Create a new instance, then run this script from an SSH command prompt.
#---------------------------------------------------------------

# update system
apt-get update
apt-get upgrade -y

# install miscellaneous tools
apt-get install -y \
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
apt-get install -y \
  apt-transport-https  \
  ca-certificates  \
  curl \
  gnupg-agent \
  software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
apt-get update
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io

# allow user ubuntu to control docker without sudo
usermod -aG docker ubuntu
newgrp docker

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# set server users, paths and permissions
groupadd mdi-edit
usermod -a -G mdi-edit ubuntu
cd /srv
mkdir data # for external data bind-mounted into running instances
mkdir mdi  # for mdi server support
mkdir mdi/config
mkdir mdi/logs
mkdir mdi/resource-scripts
chgrp -R mdi-edit mdi
chmod -R g+rwx mdi

# clone the MDI server code repository
cd /srv/mdi
sudo -u ubuntu git clone https://github.com/MiDataInt/mdi-web-server.git

# copy web server configuration templates to final location outside of the repo
cp mdi-web-server/lib/inst/*.sh  /srv/mdi/config
cp mdi-web-server/lib/inst/*.yml /srv/mdi/config

# add the server executable script to PATH
cp mdi-web-server/lib/inst/server /srv/mdi
chmod ug+x /srv/mdi/server
echo -e "\n\nexport PATH=/srv/mdi:$PATH\n" >> ~/.bashrc

# validate and report success
echo
docker --version
docker-compose --version
echo
