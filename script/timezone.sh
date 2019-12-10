#!/bin/sh
set -xe

timezone="Asia/Shanghai"

# Bring in tzdata so users could set the timezones through the environment variables
cmd="apk add --no-cache tzdata \
    && ln -sf /usr/share/zoneinfo/$timezone /etc/localtime \
    && echo $timezone > /etc/timezone"

lnmp="mariadb redis php nginx"

for i in $lnmp
do
    docker exec $i sh -c "$cmd"
done

docker-compose restart
