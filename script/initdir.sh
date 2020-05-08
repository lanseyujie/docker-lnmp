#!/bin/bash
set -xe

cd "$(dirname "$0")"

# Clean
if [ "${1#--}" = "rm" ]; then
    sudo rm -rf ../data/
fi

# data
mkdir -p data/{mysql,redis,wwwroot/default}

# logs
mkdir -p data/logs/{mysql,redis,php,nginx}
# Mysql
touch data/logs/mysql/error.log
# Redis
touch data/logs/redis/redis.log
# Php
touch data/logs/php/access.log
touch data/logs/php/error.log
touch data/logs/php/slow.log
# Nginx
touch data/logs/nginx/access.log
touch data/logs/nginx/error.log

# test
echo '<?php phpinfo();' >data/wwwroot/default/index.php
echo 'Hello World' >data/wwwroot/default/index.html

sudo chown "$USER":"$USER" -R data/

mv data/ ../
