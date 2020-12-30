FROM docker.io/library/alpine:3.12
LABEL maintainer="Okky Hendriansyah <okky.htf@gmail.com>"
ENV DNSCRYPT_PROXY_VERSION=2.0.44 \
    PLATFORM=x86_64
RUN true \
 && set -xe \
 && apk add --no-cache curl upx bind-tools tini tzdata ca-certificates \
 && curl -LO https://github.com/jedisct1/dnscrypt-proxy/releases/download/${DNSCRYPT_PROXY_VERSION}/dnscrypt-proxy-linux_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && mkdir -p /opt \
 && mv dnscrypt-proxy-linux_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz /opt \
 && cd /opt \
 && tar xvvzpf dnscrypt-proxy-linux_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && rm dnscrypt-proxy-linux_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && mv linux-${PLATFORM} dnscrypt-proxy \
 && cd dnscrypt-proxy \
 && upx --lzma dnscrypt-proxy \
 && cp example-dnscrypt-proxy.toml dnscrypt-proxy.toml \
 && chgrp -R 0 /opt/dnscrypt-proxy \
 && chmod -R g+rwx /opt/dnscrypt-proxy \
 && apk del curl upx \
 && true
HEALTHCHECK CMD dig @127.0.0.1 reddit.com || exit 1
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/opt/dnscrypt-proxy/dnscrypt-proxy"]
