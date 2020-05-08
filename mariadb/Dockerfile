FROM alpine:3.11

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ENV MARIADB_VERSION 10.4.12

RUN set -eux \
    && addgroup -g 82 -S mysql \
    && adduser -u 82 -D -S -s /sbin/nologin -G mysql mysql \
    && mkdir -p /etc/my.cnf.d/ /run/mysqld /var/log/mysql /data /initdb.d \
    && apk add --no-cache mariadb mariadb-client 'su-exec>=0.2' pwgen \
    && chown mysql:mysql -R /etc/my.cnf.d/ /run/mysqld /var/log/mysql /data /initdb.d

RUN set -eux \
    && echo -e '[client]\nport=3306\nsocket=/run/mysqld/mysqld.sock\n' >/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e '[mysqld]\nport=3306\nsocket=/run/mysqld/mysqld.sock' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'pid-file=/run/mysqld/mysqld.pid\nlog_error=/var/log/mysql/error.log' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'user=mysql\nbasedir=/usr\ndatadir=/data\ntmpdir=/tmp' >>/etc/my.cnf.d/mariadb-server.cnf \
    && echo -e 'skip-name-resolve\nbind-address=0.0.0.0' >>/etc/my.cnf.d/mariadb-server.cnf

COPY docker-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-entrypoint"]

VOLUME /data

WORKDIR /data

EXPOSE 3306

CMD ["mysqld"]
