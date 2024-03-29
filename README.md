# docker-lnmp

[![Build Docker LNMP Images](https://github.com/lanseyujie/docker-lnmp/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/lanseyujie/docker-lnmp/actions/workflows/build.yml)

## Usage

```shell
# Clone
git clone https://github.com/lanseyujie/docker-lnmp.git && cd docker-lnmp

# Build & Start
docker compose up -d

# Stop & Remove
docker compose down

# Start
docker compose start

# Restart
docker compose restart

# Stop
docker compose stop

# Logs
docker compose logs
```

## SSL Deploy

```shell
# install acme.sh
curl https://get.acme.sh | sh

# register account
acme.sh --register-account -m your@example.com

# set api key and secret
# see https://github.com/Neilpang/acme.sh/wiki/dnsapi
export Ali_Key="12345678"
export Ali_Secret="abcdefg"

# issue a certificate by validating DNS TXT records
# see https://github.com/Neilpang/acme.sh/wiki/%E8%AF%B4%E6%98%8E
export TLD=example.com
acme.sh --issue --dns dns_ali -d "$TLD" -d "*.$TLD"

# install the certificate and update it automatically
acme.sh --install-cert \
    -d "$TLD" \
    -d "*.$TLD" \
    --key-file "$(pwd)/nginx/ssl/$TLD.key" \
    --fullchain-file "$(pwd)/nginx/ssl/$TLD.cer" \
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
