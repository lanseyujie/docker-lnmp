FROM alpine:3.10

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ENV MARIADB_VERSION 10.3.18

RUN set -xe \
    && addgroup -g 82 -S mysql \
    && adduser -u 82 -D -S -s /sbin/nologin -G mysql mysql \
    && mkdir -p /var/run/mysqld /data /var/log/mysql \
    && chown mysql:mysql -R /var/run/mysqld /data /var/log/mysql \
    && apk add --no-cache mariadb mariadb-client pwgen

COPY docker-entrypoint /usr/local/bin/
COPY conf.d/my.cnf /etc/my.cnf.d/

ENTRYPOINT ["docker-entrypoint"]

VOLUME /data

WORKDIR /data

EXPOSE 3306

CMD ["mysqld"]
