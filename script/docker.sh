#!/bin/sh
set -xe

# see Install Docker Engine on Debian
# https://docs.docker.com/engine/install/debian/

if [ "$(id -u)" -ne 0 ]; then
  echo "THIS SCRIPT MUST BE RUN AS ROOT"
  exit 1
fi

# uninstall old versions
apt purge -y docker docker-engine docker.io

# install packages
apt update && apt install -y curl gnupg2

# add docker's official GPG key
# apt-key(8) will last be available in Debian 11 and Ubuntu 22.04
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor >docker.gpg
install -o root -g root -m 644 docker.gpg /etc/apt/trusted.gpg.d/

# set up the stable repository
if [ "$(lsb_release -si)" = 'Ubuntu' ]; then
  # for ubuntu
  echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
else
  # for debian
  echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
fi

# install docker engine - community
apt update && sudo apt install -y docker-ce

# use docker without sudo, need to reload shell in order to have new group settings applied
# sudo usermod -aG docker "$USER"

# install docker-compose
curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
