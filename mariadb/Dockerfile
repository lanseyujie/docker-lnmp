FROM alpine:3.14

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ENV MIRROR dl-cdn.alpinelinux.org
ENV TZ Asia/Shanghai
ENV MARIADB_VERSION 10.5.8

RUN set -eux \
    \
    # mirror
    && sed -i "s/dl-cdn.alpinelinux.org/$MIRROR/g" /etc/apk/repositories \
    \
    # timezone
    && apk add --no-cache --virtual .timezone-deps tzdata \
    && cp -f /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apk del --no-network .timezone-deps \
    \
    # add user
    && adduser -u 82 -D -S -s /sbin/nologin -G www-data mysql

RUN set -eux \
    && mkdir -p /etc/my.cnf.d /run/mysqld /var/log/mysql /data /initdb.d \
    && chown mysql:www-data -R /etc/my.cnf.d /run/mysqld /var/log/mysql /data /initdb.d \
    && apk add --no-cache mariadb mariadb-client 'su-exec>=0.2' pwgen

RUN set -eux \
    && echo -e '[client]\nport=3306\nsocket=/run/mysqld/mysqld.sock\n' >/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e '[mysqld]\nport=3306\nsocket=/run/mysqld/mysqld.sock' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'pid-file=/run/mysqld/mysqld.pid\nlog_error=/var/log/mysql/error.log' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'user=mysql\nbasedir=/usr\ndatadir=/data\ntmpdir=/tmp' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'skip-name-resolve\nbind-address=0.0.0.0' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'server-id=1\nlog-bin=/var/log/mysql/mysql-bin' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'binlog_format=mixed\nexpire_logs_days=14' >>/etc/my.cnf.d/mariadb-server.cnf

COPY docker-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-entrypoint"]

VOLUME /data

WORKDIR /data

EXPOSE 3306

CMD ["mysqld"]
