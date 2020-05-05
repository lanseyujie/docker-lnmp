#!/bin/sh
set -xe

if [ "$(docker ps | grep docker-lnmp-php | awk -F " " '{print $8}')" != "Up" ]; then
    docker-compose start php
fi
 
docker exec php sh -c "cd /usr/local/bin && php -r \"readfile('https://getcomposer.org/installer');\" | php && ln -sf /usr/local/bin/composer.phar /usr/local/bin/composer"

docker-compose restart php
