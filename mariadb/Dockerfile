FROM alpine:3.11

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ENV MARIADB_VERSION 10.4.12

RUN set -xe \
    && addgroup -g 82 -S mysql \
    && adduser -u 82 -D -S -s /sbin/nologin -G mysql mysql \
    && mkdir -p /var/run/mysqld /data /import /var/log/mysql \
    && apk add --no-cache mariadb mariadb-client pwgen \
    && chown mysql:mysql -R /var/run/mysqld /data /import /var/log/mysql

COPY docker-entrypoint /usr/local/bin/
COPY --chown=mysql:mysql conf.d/my.cnf /etc/my.cnf.d/

ENTRYPOINT ["docker-entrypoint"]

VOLUME /data

WORKDIR /data

EXPOSE 3306

CMD ["mysqld"]
