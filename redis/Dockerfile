FROM alpine:3.19

ARG MIRROR=dl-cdn.alpinelinux.org
ARG TZ=Asia/Shanghai

ENV REDIS_VERSION 7.2.3
ENV SHA256SUM 3e2b196d6eb4ddb9e743088bfc2915ccbb42d40f5a8a3edd8cb69c716ec34be7

# pre-installation
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
    # create group and user
    && addgroup -g 1000 -S redis \
    && adduser -u 1000 -D -S -h /var/cache/redis -s /sbin/nologin -G redis redis

# download & verify
RUN set -eux \
    && apk add --no-cache --virtual .fetch-deps curl \
    && mkdir -p /usr/src/redis \
    && cd /usr/src/redis \
    && curl -fSL -o redis.tar.gz https://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz \
    && echo "$SHA256SUM *redis.tar.gz" | sha256sum -c - \
    && apk del --no-network .fetch-deps

# build & install
RUN set -eux \
    \
    # grab su-exec for easy step-down from root
    && apk add --no-cache 'su-exec>=0.2' pwgen \
    && apk add --no-cache --virtual .build-deps \
        coreutils \
        gcc \
        linux-headers \
        make \
        musl-dev \
        openssl-dev \
    && cd /usr/src/redis \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    \
    # disable Redis protected mode [1] as it is unnecessary in context of Docker
    # (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
    # [1]: https://github.com/redis/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
    && grep -E '^ *createBoolConfig[(]"protected-mode",.*, *1 *,.*[)],$' /usr/src/redis/src/config.c \
    && sed -ri 's!^( *createBoolConfig[(]"protected-mode",.*, *)1( *,.*[)],)$!\10\2!' /usr/src/redis/src/config.c \
    && grep -E '^ *createBoolConfig[(]"protected-mode",.*, *0 *,.*[)],$' /usr/src/redis/src/config.c \
    # for future reference, we modify this directly in the source instead of just supplying a default configuration flag because apparently "if you specify any argument to redis-server, [it assumes] you are going to specify everything"
    # see also https://github.com/docker-library/redis/issues/4#issuecomment-50780840
    # (more exactly, this makes sure the default behavior of "save on SIGTERM" stays functional by default)
    \
    && extraJemallocConfigureFlags="--with-lg-page=12 --with-lg-hugepage=21" \
    && grep -F 'cd jemalloc && ./configure ' /usr/src/redis/deps/Makefile \
    && sed -ri 's!cd jemalloc && ./configure !&'"$extraJemallocConfigureFlags"' !' /usr/src/redis/deps/Makefile \
    && grep -F "cd jemalloc && ./configure $extraJemallocConfigureFlags " /usr/src/redis/deps/Makefile \
    \
    && export BUILD_TLS=yes \
    && make -C /usr/src/redis -j$(nproc) all \
    && make -C /usr/src/redis install \
    && mkdir -p /etc/redis /var/log/redis /srv \
    && cp -rvp /usr/src/redis/*.conf /etc/redis \
    && chown redis:redis -R /etc/redis /var/log/redis /srv \
    && rm -r /usr/src/redis \
    && strip /usr/local/bin/redis* \
    && cd / \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-network --virtual .redis-rundeps $runDeps \
    && apk del --no-network .build-deps

# configure & test
RUN set -eux \
    && sed -i 's|^bind 127.0.0.1 -::1$|bind * -::*|' /etc/redis/redis.conf \
    && sed -i 's|^logfile ""$|# logfile /var/log/redis/redis.log|' /etc/redis/redis.conf \
    && sed -i 's|^dir ./$|dir /srv|' /etc/redis/redis.conf \
    && sed -i 's|^# maxmemory <bytes>$|maxmemory 256MB|' /etc/redis/redis.conf \
    && sed -i 's|^# aclfile /etc/redis/users.acl$|aclfile /etc/redis/users.acl|' /etc/redis/redis.conf \
    && redis-server --version \
    && redis-cli --version

COPY docker-entrypoint /usr/local/bin

ENTRYPOINT ["docker-entrypoint"]

VOLUME /srv

WORKDIR /srv

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]
