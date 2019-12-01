# docker-lnmp

[![Build Status](https://travis-ci.org/lanseyujie/docker-lnmp.svg?branch=master)](https://travis-ci.org/lanseyujie/docker-lnmp)

## Docker

[Get Docker Engine - Community for Debian](https://docs.docker.com/install/linux/docker-ce/debian/ "Get Docker Engine - Community for Debian")

```bash
# update the apt package index
$ sudo apt update

# uninstall old versions
$ sudo apt remove docker docker-engine docker.io

# install packages to allow apt to use a repository over HTTPS
$ sudo apt install apt-transport-https ca-certificates curl gnupg2 -y

# add docker’s official GPG key
$ curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

#  Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88
$ sudo apt-key fingerprint 0EBFCD88

pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]

# set up the stable repository
$ echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# install docker engine - community
$ sudo apt update && sudo apt install docker-ce -y

# use docker without sudo, need to reload shell in order to have new group settings applied
$ sudo groupadd docker
$ sudo usermod -aG docker $USER

# install docker-compose
$ sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```

## Usage

```bash
# Clone
$ git clone https://github.com/lanseyujie/docker-lnmp.git

$ cd docker-lnmp

# Build & Start
$ docker-compose up -d

# Stop & Remove
$ docker-compose down

# Start
$ docker-compose start

# Restart
$ docker-compose restart

# Stop
$ docker-compose stop

# Logs
$ docker-compose logs
```

## Other

```bash
# PHP Built-in HTTP Server
$ docker run -it --rm -p 8080:8080 -v $(pwd):/data/ docker-lnmp-php:latest sh -c "php -S 0.0.0.0:8080 -t /data"
```
