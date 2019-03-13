#!/bin/sh
set -xe

# Clean
if [ "${1#--}" = "rm" ]; then
    sudo rm -rf data/
fi

mkdir -p data/wwwlogs data/wwwdata data/wwwroot

# wwwlogs
mkdir -p data/wwwlogs/mysql data/wwwlogs/redis data/wwwlogs/php data/wwwlogs/nginx
# Mysql
touch data/wwwlogs/mysql/error.log
# Redis
touch data/wwwlogs/redis/redis.log
# Php
touch data/wwwlogs/php/access.log
touch data/wwwlogs/php/error.log
touch data/wwwlogs/php/slow.log
# Nginx
touch data/wwwlogs/nginx/access.log
touch data/wwwlogs/nginx/error.log

# wwwdata
mkdir -p data/wwwdata/mysql data/wwwdata/redis

# wwwroot
mkdir -p data/wwwroot/default

# test
echo '<?php phpinfo();' > data/wwwroot/default/index.php
echo 'Hello World' > data/wwwroot/default/index.html

sudo chown $USER:$USER -R data/
