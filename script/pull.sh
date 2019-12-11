#!/bin/sh
set -ex

arch=$(dpkg --print-architecture)

if [ $arch != "amd64" ]; then
    echo "unsupported architecture: $arch"
    exit;
fi

lnmp="mariadb redis php nginx"

for i in $lnmp
do
    docker pull registry.cn-qingdao.aliyuncs.com/lanseyujie/docker-lnmp-$i:latest
    docker tag registry.cn-qingdao.aliyuncs.com/lanseyujie/docker-lnmp-$i:latest docker-lnmp-$i:latest
    docker image rm registry.cn-qingdao.aliyuncs.com/lanseyujie/docker-lnmp-$i:latest
done
