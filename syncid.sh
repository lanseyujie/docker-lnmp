#!/bin/sh
set -xe

UID=$(id -u $USER)
GID=$(id -g $USER)

if [ $UID -gt 0 ] && [ $GID -gt 0 ] ; then
    docker-compose restart
    docker exec php sh -c "apk --no-cache add shadow && usermod -u $UID www-data && groupmod -g $GID www-data && apk del shadow"
fi

docker-compose restart
