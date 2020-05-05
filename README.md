# docker-lnmp

[![Build Status](https://travis-ci.org/lanseyujie/docker-lnmp.svg?branch=master)](https://travis-ci.org/lanseyujie/docker-lnmp)

## Get Docker

[Get Docker Engine - Community for Debian](https://docs.docker.com/install/linux/docker-ce/debian/ "Get Docker Engine - Community for Debian")

```bash
# update the apt package index
$ sudo apt update

# uninstall old versions
$ sudo apt remove docker docker-engine docker.io

# install packages to allow apt to use a repository over HTTPS
$ sudo apt install apt-transport-https ca-certificates curl gnupg2 -y

# add docker's official GPG key
$ curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

#  Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88
$ sudo apt-key fingerprint 0EBFCD88

pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]

# set up the stable repository
# for debian
$ echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
# for ubuntu
$ echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# install docker engine - community
$ sudo apt update && sudo apt install docker-ce -y

# use docker without sudo, need to reload shell in order to have new group settings applied
$ sudo usermod -aG docker $USER

# install docker-compose
$ sudo curl -L https://github.com/docker/compose/releases/download/1.25.5/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
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

## SSL Deploy

```bash
# install acme.sh
curl https://get.acme.sh | sh

# set api key
# see https://github.com/Neilpang/acme.sh/wiki/dnsapi
export Ali_Key="12345678"
export Ali_Secret="abcdefg"

# issue a cert
# see https://github.com/Neilpang/acme.sh/wiki/%E8%AF%B4%E6%98%8E
acme.sh --issue --dns dns_ali -d example.com -d *.example.com

# auto update
acme.sh --install-cert \
    -d example.com \
    -d *.example.com \
    --key-file $(pwd)/nginx/ssl/example.com.key \
    --fullchain-file $(pwd)/nginx/ssl/example.com.cer \
    --reloadcmd "docker restart nginx"
```

## Other

```bash
# PHP Built-in HTTP Server
$ docker run -it --rm -p 8080:8080 -v $(pwd):/data/ docker-lnmp-php:latest sh -c "php -S 0.0.0.0:8080 -t /data"

# Auto Backup Database
$ echo "0 3 * * * $(pwd)/script/autobak.sh -uroot -p123456 -dwww" | sudo tee -a /var/spool/cron/crontabs/$USER && sudo chmod 600 /var/spool/cron/crontabs/$USER && sudo chown $USER:crontab /var/spool/cron/crontabs/$USER && sudo service cron restart
```
