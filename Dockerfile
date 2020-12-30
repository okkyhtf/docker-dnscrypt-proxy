FROM docker.io/alpine:3.12
LABEL maintainer="Okky Hendriansyah <okky.htf@gmail.com>"
ENV DNSCRYPT_PROXY_VERSION=2.0.44
ENV UPX_VERSION=3.96
ENV OS=linux
ENV PLATFORM=x86_64
RUN true \
 && set -xe \
 && apk add --no-cache curl bind-tools tini tzdata ca-certificates xz \
 && curl -LO https://github.com/jedisct1/dnscrypt-proxy/releases/download/${DNSCRYPT_PROXY_VERSION}/dnscrypt-proxy-${OS}_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && mkdir -p /opt \
 && mv dnscrypt-proxy-${OS}_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz /opt \
 && cd /opt \
 && tar xvvzpf dnscrypt-proxy-${OS}_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && rm dnscrypt-proxy-${OS}_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && mv ${OS}-${PLATFORM} dnscrypt-proxy \
 && curl -LO https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-${PLATFORM}_${OS}.tar.xz \
 && tar -xf upx-${UPX_VERSION}-${PLATFORM}_${OS}.tar.xz \
 && mv upx-${UPX_VERSION}-${PLATFORM}_${OS}/upx /usr/bin/upx \
 && rm -rf upx* \
 && cd dnscrypt-proxy \
 && upx --lzma dnscrypt-proxy \
 && cp example-dnscrypt-proxy.toml dnscrypt-proxy.toml \
 && chgrp -R 0 /opt/dnscrypt-proxy \
 && chmod -R g+rwx /opt/dnscrypt-proxy \
 && mv dnscrypt-proxy /usr/bin/dnscrypt-proxy \
 && apk del curl xz \
 && rm /usr/bin/upx \
 && true
HEALTHCHECK CMD dig @127.0.0.1 reddit.com || exit 1
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/dnscrypt-proxy", "--config", "/opt/dnscrypt-proxy/dnscrypt-proxy.toml"]
