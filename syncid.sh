#!/bin/sh
set -xe

UID=$(id -u $USER)
GID=$(id -g $USER)

if [ $UID -gt 0 ] && [ $GID -gt 0 ] ; then
    docker exec php sh -c "apk --no-cache add shadow && usermod -u $UID www-data && groupmod -g $GID www-data && apk del shadow"
    
    docker exec php sh -c "apk --no-cache add shadow && usermod -u $UID nginx && groupmod -g $GID nginx && apk del shadow"
fi

docker-compose restart php

docker-compose restart nginx
