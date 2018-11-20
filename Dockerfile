FROM docker.io/arm32v6/alpine:3.8
LABEL maintainer="Okky Hendriansyah <okky.htf@gmail.com>"
ENV DNSCRYPT_PROXY_VERSION=2.0.18 \
    PLATFORM=arm
RUN true \
 && set -xe \
 && apk add --no-cache curl bind-tools tini tzdata ca-certificates \
 && curl -LO https://github.com/jedisct1/dnscrypt-proxy/releases/download/${DNSCRYPT_PROXY_VERSION}/dnscrypt-proxy-linux_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && apk del curl \
 && mkdir -p /opt \
 && mv dnscrypt-proxy-linux_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz /opt \
 && cd /opt \
 && tar xvvzpf dnscrypt-proxy-linux_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && rm dnscrypt-proxy-linux_${PLATFORM}-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && mv linux-${PLATFORM} dnscrypt-proxy \
 && cd dnscrypt-proxy \
 && cp example-dnscrypt-proxy.toml dnscrypt-proxy.toml \
 && chgrp -R 0 /opt/dnscrypt-proxy \
 && chmod -R g+rwx /opt/dnscrypt-proxy \
 && true
HEALTHCHECK CMD dig @127.0.0.1 reddit.com || exit 1
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/opt/dnscrypt-proxy/dnscrypt-proxy"]

