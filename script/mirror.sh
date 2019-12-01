#!/bin/sh
set -xe

cmd="sed -i 's/dl-cdn.alpinelinux.org/mirrors.huaweicloud.com/g' /etc/apk/repositories"

docker exec mariadb sh -c "$cmd"
docker exec redis sh -c "$cmd"
docker exec nginx sh -c "$cmd"
docker exec php sh -c "$cmd"

docker-compose restart
