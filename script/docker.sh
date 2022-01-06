#!/bin/sh
set -xe

# see Install Docker Engine on Debian
# https://docs.docker.com/engine/install/debian/

if [ "$(id -u)" -ne 0 ]; then
  echo "THIS SCRIPT MUST BE RUN AS ROOT"
  exit 1
fi

# uninstall old versions
apt purge -y docker docker.io

# install packages
apt update && apt install -y curl gnupg2

# add docker's official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg

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

# install docker compose
# https://docs.docker.com/compose/cli-command/#install-on-linux
mkdir -p /usr/local/lib/docker/cli-plugins
curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
