FROM alpine:3.8

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ENV MARIADB_VERSION 10.2.19

RUN set -xe \
    && addgroup -S mysql \
    && adduser -D -S -s /sbin/nologin -G mysql mysql \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && mkdir -p /etc/mysql/conf.d/ /var/run/mysqld /data /var/log/mysql \
    && chown mysql:mysql -R /etc/mysql/conf.d/ /var/run/mysqld /data /var/log/mysql \
    && apk add --no-cache mariadb mariadb-client pwgen \
    && echo -e '\n!includedir /etc/mysql/conf.d/' >> /etc/mysql/my.cnf \
    \
    # Bring in tzdata so users could set the timezones through the environment variables
    && apk add --no-cache tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

COPY docker-entrypoint /usr/local/bin/
COPY conf.d/my.cnf /etc/mysql/

ENTRYPOINT ["docker-entrypoint"]

VOLUME /data

WORKDIR /data

EXPOSE 3306

CMD ["mysqld"]