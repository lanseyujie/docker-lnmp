FROM alpine:3.17

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ARG MIRROR=dl-cdn.alpinelinux.org
ARG TZ=Asia/Shanghai

ENV MARIADB_VERSION 10.6.12

RUN set -eux \
    \
    # mirror
    && sed -i "s/dl-cdn.alpinelinux.org/$MIRROR/g" /etc/apk/repositories \
    \
    # ca-certs && timezone
    && apk add --no-cache ca-certificates tzdata \
    && cp -f /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    \
    # add user
    && adduser -u 82 -D -S -s /sbin/nologin -G www-data mysql

RUN set -eux \
    && mkdir -p /etc/my.cnf.d /var/run/mysqld /var/log/mysql /var/lib/mysql /initdb.d \
    && chown mysql:www-data -R /etc/my.cnf.d /var/run/mysqld /var/log/mysql /var/lib/mysql /initdb.d \
    && apk add --no-cache mariadb mariadb-client 'su-exec>=0.2' pwgen

RUN set -eux \
    && echo -e '[client]\nport=3306\nsocket=/var/run/mysqld/mysqld.sock\n' >/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e '[mysqld]\nport=3306\nsocket=/var/run/mysqld/mysqld.sock' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'pid-file=/var/run/mysqld/mysqld.pid\nlog_error=/var/log/mysql/error.log' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'user=mysql\nbasedir=/usr\ndatadir=/var/lib/mysql\ntmpdir=/tmp' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'skip-name-resolve\nbind-address=0.0.0.0' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'server-id=1\nlog-bin=/var/log/mysql/mysql-bin' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'binlog_format=mixed\nexpire_logs_days=14' >>/etc/my.cnf.d/mariadb-server.cnf

COPY docker-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-entrypoint"]

VOLUME /var/lib/mysql

WORKDIR /var/lib/mysql

EXPOSE 3306

CMD ["mysqld"]
