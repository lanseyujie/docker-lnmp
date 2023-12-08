FROM alpine:3.19

LABEL maintainer="Wildlife <admin@lanseyujie.com>"

ARG MIRROR=dl-cdn.alpinelinux.org
ARG TZ=Asia/Shanghai

ENV NGINX_VERSION 1.25.3
# https://nginx.org/en/pgp_keys.html
ENV GPG_KEYS B0F4253373F8F6F510D42178520A9993A1C052F8 41DB92713D3BF4BFF3EE91069C5E7FA2F54977D4 7338973069ED3F443F4D37DFA64FD5B17ADB39A8 13C82A63B603576156E30A4EA0EA981B66B0D967 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
ENV SHA256SUM 64c5b975ca287939e828303fa857d22f142b251f17808dfe41733512d9cded86

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
    && addgroup -g 1000 -S nginx \
    && adduser -u 1000 -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

RUN set -eux \
    && apk add --no-cache --virtual .fetch-deps gnupg curl \
    && mkdir -p /usr/src/nginx \
    && cd /usr/src/nginx \
    && curl -fSL -o nginx.tar.gz https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    && curl -fSL -o nginx.tar.gz.asc https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc \
    && echo "$SHA256SUM *nginx.tar.gz" | sha256sum -c - \
    && export GNUPGHOME="$(mktemp -d)" \
    && for key in $GPG_KEYS; do \
        gpg --batch --keyserver keyserver.ubuntu.com --keyserver-options timeout=10 --recv-keys "$key"; \
    done \
    && gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
    && apk del --no-network .fetch-deps

# https://nginx.org/en/docs/configure.html
RUN set -eux \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        make \
        gd-dev \
        libc-dev \
        pcre-dev \
        zlib-dev \
        geoip-dev \
        libxslt-dev \
        openssl-dev \
        linux-headers \
    && mkdir -p /usr/lib/nginx/modules /etc/nginx/conf.d /etc/nginx/ssl /srv/default /var/cache/nginx /var/log/nginx \
    && cd /usr/src/nginx \
    && tar -xzf nginx.tar.gz -C /usr/src/nginx --strip-components=1 \
    && rm nginx.tar.gz \
    && CONFIG="\
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
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
        --with-compat \
        --with-threads \
        --with-file-aio \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_v3_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_auth_request_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_stub_status_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
        --with-stream_geoip_module=dynamic \
    " \
    && ./configure $CONFIG \
    && make -j$(nproc) \
    && make install \
    && install -o nginx -g nginx -m 644 html/index.html /srv/default \
    && strip /usr/sbin/nginx /usr/lib/nginx/modules/*.so \
    && rm -rf /etc/nginx/html /usr/src/nginx \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-network --virtual .nginx-rundeps $runDeps \
    && apk del --no-network .build-deps \
    && chown nginx:nginx -R /usr/lib/nginx /etc/nginx /srv /var/cache/nginx /var/log/nginx

RUN set -eux \
    \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY --chown=nginx:nginx nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx conf.d/default.http.conf /etc/nginx/conf.d/default.http.conf

WORKDIR /srv

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
