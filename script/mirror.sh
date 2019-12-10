#!/bin/sh
set -xe

mirror="mirrors.huaweicloud.com"

cmd="sed -i 's/dl-cdn.alpinelinux.org/$mirror/g' /etc/apk/repositories"

lnmp="mariadb redis php nginx"

for i in $lnmp
do
    docker exec $i sh -c "$cmd"
done

docker-compose restart
