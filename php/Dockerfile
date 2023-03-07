FROM alpine:3.17

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ARG MIRROR=dl-cdn.alpinelinux.org
ARG TZ=Asia/Shanghai

ENV PHP_VERSION 8.2.3
ENV GPG_KEYS 39B641343D8C104B2B146DC3F9C39DC0B9698544 E60913E4DF209907D8E30D96659A97C9CF2A795A 1198C0117593497A5EC5C199286AF1F9897469DC
ENV SHA256SUM 7c475bcbe61d28b6878604b1b6f387f39d1a63b5f21fa8156fd7aa615d43e259

# dependencies required for running "phpize"
ENV PHPIZE_DEPS \
        autoconf \
        dpkg-dev dpkg \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkgconf \
        re2c

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

RUN set -eux \
    \
    # ca-certs && timezone
    && apk add --no-cache ca-certificates tzdata \
    && cp -f /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    \
    # mirror
    && sed -i "s/dl-cdn.alpinelinux.org/$MIRROR/g" /etc/apk/repositories \
    \
    # add user
    && adduser -u 82 -D -S -s /sbin/nologin -G www-data www-data

RUN set -eux \
    && apk add --no-cache --virtual .fetch-deps gnupg curl \
    && mkdir -p /usr/src/php \
    && cd /usr/src/php \
    && curl -fSL -o php.tar.gz https://www.php.net/get/php-$PHP_VERSION.tar.gz/from/this/mirror \
    && curl -fSL -o php.tar.gz.asc https://www.php.net/get/php-$PHP_VERSION.tar.gz.asc/from/this/mirror \
    && echo "$SHA256SUM *php.tar.gz" | sha256sum -c - \
    && export GNUPGHOME="$(mktemp -d)" \
    && for key in $GPG_KEYS; do \
        gpg --batch --keyserver keyserver.ubuntu.com --keyserver-options timeout=10 --recv-keys "$key"; \
    done \
    && gpg --batch --verify php.tar.gz.asc php.tar.gz \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" php.tar.gz.asc \
    && apk del --no-network .fetch-deps

RUN set -eux \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        icu-dev \
        oniguruma-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        freetype-dev \
        openssl-dev \
        sqlite-dev \
        curl-dev \
        gettext-dev \
        libedit-dev \
        libxslt-dev \
        libxml2-dev \
        libzip-dev \
    && mkdir -p /usr/local/etc/php/conf.d /data/default /var/log/php \
    && cd /usr/src/php \
    && tar -xzf php.tar.gz -C /usr/src/php --strip-components=1 \
    && rm php.tar.gz \
    && export CFLAGS="$PHP_CFLAGS" \
    && export CPPFLAGS="$PHP_CPPFLAGS" \
    && export LDFLAGS="$PHP_LDFLAGS" \
    && CONFIG="\
        --with-config-file-path=/usr/local/etc/php \
        --with-config-file-scan-dir=/usr/local/etc/php/conf.d \
        --with-libdir=/usr/lib \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
        --disable-cgi \
        --disable-rpath \
        --enable-option-checking=fatal \
        --enable-fpm \
        --enable-bcmath \
        --enable-mbstring \
        --enable-mbregex \
        --enable-mysqlnd \
        --enable-intl \
        --enable-pcntl \
        --enable-shmop \
        --enable-soap \
        --enable-sockets \
        --enable-sysvsem \
        --enable-ftp \
        --enable-exif \
        --enable-gd \
        --with-webp \
        --with-jpeg \
        --with-freetype \
        --with-openssl \
        --with-curl \
        --with-gettext \
        --with-libedit \
        --with-mhash \
        --with-mysqli=mysqlnd \
        --with-pdo-mysql=mysqlnd \
        --with-sqlite3=/usr \
        --with-pdo-sqlite=/usr \
        --with-xsl \
        --with-zlib \
        --with-zip \
    " \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --build="$gnuArch" $CONFIG \
    && make -j$(nproc) \
    && find -type f -name '*.a' -delete \
    && make install \
    && find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true \
    && make clean \
    && echo '<?php phpinfo();' > /data/default/index.php \
    && cp -v php.ini-* /usr/local/etc/php \
    && rm -rf /usr/src/php \
    && cd / \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-network --virtual .php-rundeps $runDeps \
    && apk del --no-network .build-deps \
    && chown www-data:www-data -R /usr/local/etc/php /data /var/log/php

RUN set -eux \
    && cd /usr/local/etc \
    \
    # for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
    && sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null \
    && sed -i 's/;pid = run\/php-fpm.pid/pid = \/var\/run\/php-fpm.pid/' php-fpm.conf \
    && sed -i 's/;error_log = log\/php-fpm.log/error_log = \/var\/log\/php\/error.log/' php-fpm.conf \
    && sed -i 's/;log_limit = 4096/log_limit = 8192/' php-fpm.conf \
    && sed -i 's/;daemonize = yes/daemonize = no/' php-fpm.conf \
    \
    # www.conf
    && cp -v php-fpm.d/www.conf.default php-fpm.d/www.conf \
    && sed -i 's/listen = 127.0.0.1:9000/listen = 9000/' php-fpm.d/www.conf \
    && sed -i 's/pm.max_children = 5/pm.max_children = 20/' php-fpm.d/www.conf \
    && sed -i 's/pm.start_servers = 2/pm.start_servers = 10/' php-fpm.d/www.conf \
    && sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 10/' php-fpm.d/www.conf \
    && sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 20/' php-fpm.d/www.conf \
    && sed -i 's/;pm.max_requests = 500/pm.max_requests = 1024/' php-fpm.d/www.conf \
    && sed -i 's/;access.log = log\/\$pool.access.log/access.log = \/var\/log\/php\/access.log/' php-fpm.d/www.conf \
    && sed -i 's/;slowlog = log\/\$pool.log.slow/slowlog = \/var\/log\/php\/slow.log/' php-fpm.d/www.conf \
    && sed -i 's/;catch_workers_output = yes/catch_workers_output = yes/' php-fpm.d/www.conf \
    && sed -i 's/;decorate_workers_output = no/decorate_workers_output = no/' php-fpm.d/www.conf \
    \
    # php.ini
    && cp -v php/php.ini-production php/php.ini \
    && disable="passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server" \
    && sed -i "s/disable_functions =/disable_functions = $disable/" php/php.ini \
    && sed -i 's/expose_php = On/expose_php = Off/' php/php.ini \
    && sed -i 's/;date.timezone =/;date.timezone = Asia\/Shanghai/' php/php.ini \
    \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stderr /var/log/php/error.log \
    && php --version

COPY docker-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-entrypoint"]

WORKDIR /data

EXPOSE 9000

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

CMD ["php-fpm"]
