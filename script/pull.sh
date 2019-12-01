#!/bin/sh
set -ex

lnmp="mariadb redis php nginx"

for i in $lnmp
do
    docker pull registry.cn-qingdao.aliyuncs.com/lanseyujie/docker-lnmp-$i:latest
    docker tag registry.cn-qingdao.aliyuncs.com/lanseyujie/docker-lnmp-$i:latest docker-lnmp-$i:latest
    docker image rm registry.cn-qingdao.aliyuncs.com/lanseyujie/docker-lnmp-$i:latest
done
