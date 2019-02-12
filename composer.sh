#!/bin/sh
set -xe

docker-compose restart php
 
docker exec php sh -c "cd /usr/local/bin && php -r \"readfile('https://getcomposer.org/installer');\" | php && ln -sf /usr/local/bin/composer.phar /usr/local/bin/composer"

docker-compose restart php
