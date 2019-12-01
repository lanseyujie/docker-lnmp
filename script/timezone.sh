#!/bin/sh
set -xe

timezone="Asia/Shanghai"

# Bring in tzdata so users could set the timezones through the environment variables
cmd="apk add --no-cache tzdata \
    && ln -sf /usr/share/zoneinfo/$timezone /etc/localtime \
    && echo $timezone > /etc/timezone"

docker exec mariadb sh -c "$cmd"
docker exec redis sh -c "$cmd"
docker exec nginx sh -c "$cmd"
docker exec php sh -c "$cmd"

docker-compose restart
