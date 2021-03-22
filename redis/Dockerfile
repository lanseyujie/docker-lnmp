FROM alpine:3.13

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ENV REDIS_VERSION 6.2.1
ENV SHA256SUM cd222505012cce20b25682fca931ec93bd21ae92cb4abfe742cf7b76aa907520

RUN set -eux \
    && apk add --no-cache --virtual .fetch-deps curl \
    && mkdir -p /usr/src/redis \
    && cd /usr/src/redis \
    && curl -fSL -o redis.tar.gz http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz \
    && echo "$SHA256SUM *redis.tar.gz" | sha256sum -c - \
    && apk del --no-network .fetch-deps

RUN set -eux \
    && addgroup -g 82 -S redis \
    && adduser -u 82 -D -S -s /sbin/nologin -G redis redis \
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
    && mkdir -p /data /var/log/redis \
    && cd /usr/src/redis \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    \
    # disable Redis protected mode [1] as it is unnecessary in context of Docker
    # (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
    # [1]: https://github.com/antirez/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
	&& grep -E '^ *createBoolConfig[(]"protected-mode",.*, *1 *,.*[)],$' /usr/src/redis/src/config.c \
	&& sed -ri 's!^( *createBoolConfig[(]"protected-mode",.*, *)1( *,.*[)],)$!\10\2!' /usr/src/redis/src/config.c \
	&& grep -E '^ *createBoolConfig[(]"protected-mode",.*, *0 *,.*[)],$' /usr/src/redis/src/config.c \
    # for future reference, we modify this directly in the source instead of just supplying a default configuration flag because apparently "if you specify any argument to redis-server, [it assumes] you are going to specify everything"
    # see also https://github.com/docker-library/redis/issues/4#issuecomment-50780840
    # (more exactly, this makes sure the default behavior of "save on SIGTERM" stays functional by default)
    \
    && export BUILD_TLS=yes \
    && make -C /usr/src/redis -j$(nproc) all \
    && make -C /usr/src/redis install \
    && strip /usr/local/bin/redis* \
    && cp -v *.conf /etc \
    && rm -r /usr/src/redis \
    && cd / \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-network --virtual .redis-rundeps $runDeps \
    && apk del --no-network .build-deps \
    && chown redis:redis -R /data /var/log/redis

RUN set -eux \
    && sed -i 's/^bind 127.0.0.1 -::1$/bind * -::*/' /etc/redis.conf \
    && sed -i 's/^logfile ""$/logfile \/var\/log\/redis\/redis.log/' /etc/redis.conf \
    && sed -i 's/^dir .\/$/dir \/data/' /etc/redis.conf \
    && sed -i 's/^# maxmemory <bytes>$/maxmemory 256MB/' /etc/redis.conf \
    && redis-server --version \
    && redis-cli --version

COPY docker-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-entrypoint"]

VOLUME /data

WORKDIR /data

EXPOSE 6379

CMD ["redis-server", "/etc/redis.conf"]
