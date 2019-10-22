FROM alpine:3.10

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ENV MARIADB_VERSION 10.3.17

RUN set -xe \
    && addgroup -g 82 -S mysql \
    && adduser -u 82 -D -S -s /sbin/nologin -G mysql mysql \
    # && sed -i 's/dl-cdn.alpinelinux.org/mirrors.huaweicloud.com/g' /etc/apk/repositories \
    && mkdir -p /var/run/mysqld /data /var/log/mysql \
    && chown mysql:mysql -R /var/run/mysqld /data /var/log/mysql \
    && apk add --no-cache mariadb mariadb-client pwgen \
    \
    # Bring in tzdata so users could set the timezones through the environment variables
    && apk add --no-cache tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

COPY docker-entrypoint /usr/local/bin/
COPY conf.d/my.cnf /etc/my.cnf.d/

ENTRYPOINT ["docker-entrypoint"]

VOLUME /data

WORKDIR /data

EXPOSE 3306

CMD ["mysqld"]
