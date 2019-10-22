FROM alpine:3.10

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ENV NGINX_VERSION 1.17.3

RUN set -xe \
    && GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
    && CONFIG="\
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/etc/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_mp4_module \
        --with-http_gzip_static_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
    " \
    && addgroup -g 82 -S nginx \
    && adduser -u 82 -D -S -s /sbin/nologin -G nginx nginx \
    # && sed -i 's/dl-cdn.alpinelinux.org/mirrors.huaweicloud.com/g' /etc/apk/repositories \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        curl \
        gnupg \
    && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
    && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && found=''; \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
    gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
    && rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
    && mkdir -p /usr/src/nginx /etc/nginx/conf.d /etc/nginx/ssl /data/default /var/cache/nginx /var/log/nginx \
    && tar -xzf nginx.tar.gz -C /usr/src/nginx --strip-components=1 \
    && rm nginx.tar.gz \
    && cd /usr/src/nginx \
    && ./configure $CONFIG \
    && make -j$(nproc) \
    && make install \
    && rm -rf /etc/nginx/html/ \
    && install -m644 html/index.html /data/default \
    && strip /usr/sbin/nginx* \
    && rm -rf /usr/src/nginx \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-cache --virtual .nginx-rundeps $runDeps \
    && apk del .build-deps \
    \
    # Bring in tzdata so users could set the timezones through the environment variables
    && apk add --no-cache tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf

COPY conf.d/http/default.conf /etc/nginx/conf.d/http/default.conf

COPY conf.d/stream/default.conf /etc/nginx/conf.d/stream/default.conf

WORKDIR /data

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
