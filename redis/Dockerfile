FROM alpine:3.11

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ENV REDIS_VERSION 5.0.7

RUN set -ex \
    && SHA256SUM=61db74eabf6801f057fd24b590232f2f337d422280fd19486eca03be87d3a82b \
    && addgroup -g 82 -S redis \
    && adduser -u 82 -D -S -s /sbin/nologin -G redis redis \
    \
    # grab su-exec for easy step-down from root
    && apk add --no-cache 'su-exec>=0.2' \
    && apk add --no-cache --virtual .build-deps \
        coreutils \
        gcc \
        linux-headers \
        make \
        musl-dev \
        curl \
    && curl -fSL http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz -o redis.tar.gz \
    && echo "$SHA256SUM *redis.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/redis /data /var/log/redis \
    && chown redis:redis -R /data /var/log/redis \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    \
    # disable Redis protected mode [1] as it is unnecessary in context of Docker
    # (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
    # [1]: https://github.com/antirez/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
    && grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 1$' /usr/src/redis/src/server.h \
    && sed -ri 's!^(#define CONFIG_DEFAULT_PROTECTED_MODE) 1$!\1 0!' /usr/src/redis/src/server.h \
    && grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 0$' /usr/src/redis/src/server.h \
    \
    # for future reference, we modify this directly in the source instead of just supplying a default configuration flag because apparently "if you specify any argument to redis-server, [it assumes] you are going to specify everything"
    # see also https://github.com/docker-library/redis/issues/4#issuecomment-50780840
    # (more exactly, this makes sure the default behavior of "save on SIGTERM" stays functional by default)
    && make -C /usr/src/redis -j$(nproc) \
    && make -C /usr/src/redis install \
    && strip /usr/local/bin/redis* \
    && rm -r /usr/src/redis \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --virtual .redis-rundeps $runDeps \
    && apk del .build-deps \
    && redis-server --version

COPY redis.conf /etc/redis.conf

COPY docker-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-entrypoint"]

VOLUME /data

WORKDIR /data

EXPOSE 6379

CMD ["redis-server", "/etc/redis.conf"]
