# docker-lnmp

![Publish Docker LNMP Image](https://github.com/lanseyujie/docker-lnmp/workflows/Publish%20Docker%20LNMP%20Image/badge.svg)

## Usage

```shell
# Clone
git clone https://github.com/lanseyujie/docker-lnmp.git && cd docker-lnmp

# Build & Start
docker-compose up -d

# Stop & Remove
docker-compose down

# Start
docker-compose start

# Restart
docker-compose restart

# Stop
docker-compose stop

# Logs
docker-compose logs
```

## SSL Deploy

```shell
# install acme.sh
curl https://get.acme.sh | sh

# set api key
# see https://github.com/Neilpang/acme.sh/wiki/dnsapi
export Ali_Key="12345678"
export Ali_Secret="abcdefg"

# issue a cert
# see https://github.com/Neilpang/acme.sh/wiki/%E8%AF%B4%E6%98%8E
acme.sh --issue --dns dns_ali -d example.com -d *.example.com

# auto update
acme.sh --install-cert \
    -d example.com \
    -d *.example.com \
    --key-file $(pwd)/nginx/ssl/example.com.key \
    --fullchain-file $(pwd)/nginx/ssl/example.com.cer \
    --reloadcmd "docker restart nginx"
```

## Other

```shell
# PHP Built-in HTTP Server
docker run -it --rm -p 8080:8080 -v $(pwd):/data/ docker-lnmp-php:latest sh -c "php -S 0.0.0.0:8080 -t /data"

# Auto Backup Database
cd docker-lnmp && crontab -l | {
    cat
    echo "0 3 * * * $(pwd)/script/autobak.sh -uroot -p123456 -dwww > /dev/null"
} | crontab -
```
