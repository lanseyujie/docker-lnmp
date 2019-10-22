FROM alpine:3.10

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ENV PHP_VERSION 7.3.10

RUN set -xe \
    && GPG_KEYS="CBAF69F173A0FEA4B537F470D66C9593118BCCB6 F38252826ACD957EF380D39F2F7956BC5DA04B5D" \
    && SHA256SUM=fb670723a9b8fda31c89529f27e0dda289d8af4b6ce9f152c8010876639c0fb4 \
    && CONFIG="\
        --with-config-file-path=/usr/local/etc \
        --with-config-file-scan-dir=/usr/local/etc/php \
        --with-libdir=/usr/lib \
        --with-webp-dir=/usr/include \
        --with-jpeg-dir=/usr/include \
        --with-png-dir=/usr/include \
        --with-freetype-dir=/usr/include \
        --with-libxml-dir=/usr/include \
        --with-iconv-dir=/usr/include \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
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
        --enable-zip \
        --enable-exif \
        --enable-ftp \
        --with-openssl \
        --with-curl \
        --with-gd \
        --with-gettext \
        --with-libedit \
        --with-mhash \
        --with-mysqli=mysqlnd \
        --with-pdo-mysql=mysqlnd \
        --with-xmlrpc \
        --with-xsl \
        --with-zlib \
        --with-libzip \
    " \
    # ensure www-data user exists, 82 is the standard uid/gid for "www-data" in Alpine
    && addgroup -g 82 -S www-data \
    && adduser -u 82 -D -S -s /sbin/nologin -G www-data www-data \
    # && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        gcc \
        g++ \
        make \
        libc-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        openssl-dev \
        libxslt-dev \
        libxml2-dev \
        libzip-dev \
        libedit-dev \
        gettext-dev \
        freetype-dev \
        curl-dev \
        icu-dev \
        file \
        bison \
        re2c \
        dpkg \
        dpkg-dev \
        curl \
        gnupg \
    && curl -fSL https://www.php.net/get/php-$PHP_VERSION.tar.gz/from/this/mirror -o php.tar.gz \
    && echo "$SHA256SUM *php.tar.gz" | sha256sum -c - \
    && curl -fSL https://www.php.net/get/php-$PHP_VERSION.tar.gz.asc/from/this/mirror -o php.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && found=''; \
    for key in $GPG_KEYS; do \
        gpg --batch --keyserver ha.pool.sks-keyservers.net --keyserver-options timeout=10 --recv-keys "$key" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
    gpg --batch --verify php.tar.gz.asc php.tar.gz \
    && rm -rf "$GNUPGHOME" php.tar.gz.asc \
    && mkdir -p /usr/src/php /usr/local/etc/php /data/default /var/log/php \
    && chown www-data:www-data -R /usr/src/php /usr/local/etc/php /data/default /var/log/php \
    && tar -xzf php.tar.gz -C /usr/src/php --strip-components=1 \
    && rm php.tar.gz \
    && cd /usr/src/php \
    \
    # Apply stack smash protection to functions using local buffers and alloca()
    # Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
    # Enable optimization (-O2)
    # Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
    # Adds GNU HASH segments to generated executables (this is used if present, and is much faster than sysv hash; in this configuration, sysv hash is also generated)
    # https://github.com/docker-library/php/issues/272
    # -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
    && export CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64" \
    && CPPFLAGS="$CFLAGS" \
    && LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --build="$gnuArch" $CONFIG \
    && make -j$(nproc) \
    && make install \
    && { find /usr/local/bin /usr/local/sbin /usr/local/lib/php/extensions -type f -perm +0111 -exec strip --strip-all '{}' + || true; } \
    && make clean \
    && echo '<?php phpinfo();' > /data/default/index.php \
    && cp -v php.ini-production /usr/local/etc/php.ini \
    && cd / \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-cache --virtual .php-rundeps $runDeps \
    && apk del --no-network .build-deps \
    \
    # https://github.com/docker-library/php/issues/443
    && pecl update-channels \
    && rm -rf /tmp/pear ~/.pearrc /usr/src/php \
    \
    # Bring in tzdata so users could set the timezones through the environment variables
    && apk add --no-cache tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
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
    && cp php-fpm.d/www.conf.default php-fpm.d/www.conf \
    && sed -i 's/listen = 127.0.0.1:9000/listen = 9000/' php-fpm.d/www.conf \
    && sed -i 's/pm.max_children = 5/pm.max_children = 20/' php-fpm.d/www.conf \
    && sed -i 's/pm.start_servers = 2/pm.start_servers = 10/' php-fpm.d/www.conf \
    && sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 10/' php-fpm.d/www.conf \
    && sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 20/' php-fpm.d/www.conf \
    && sed -i 's/;pm.max_requests = 500/pm.max_requests = 1024/' php-fpm.d/www.conf \
    && sed -i 's/;access.log = log\/$pool.access.log/access.log = \/var\/log\/php\/access.log/' php-fpm.d/www.conf \
    && sed -i 's/;slowlog = log\/$pool.log.slow/slowlog = \/var\/log\/php\/slow.log/' php-fpm.d/www.conf \
    && sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 100/' php-fpm.d/www.conf \
    && sed -i 's/;catch_workers_output = yes/catch_workers_output = yes/' php-fpm.d/www.conf \
    && sed -i 's/;decorate_workers_output = no/decorate_workers_output = no/' php-fpm.d/www.conf \
    \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stderr /var/log/php/error.log

COPY docker-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-entrypoint"]

WORKDIR /data

EXPOSE 9000

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

CMD ["php-fpm"]
