FROM docker.io/library/alpine:3.7
LABEL maintainer="Okky Hendriansyah <okky.htf@gmail.com>"

ENV DNSCRYPT_PROXY_VERSION=2.0.8 \
    FALLBACK_RESOLVER=203.142.82.222 \
    PLATFORM=x86_64

RUN true \
 && set -xe \
 && apk add --no-cache curl bind-tools tini tzdata \
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
 && sed -i -E "s/\'127\.0\.0\.1\:53\'\, \'\[\:\:1\]\:53\'/'0.0.0.0:53'/g" dnscrypt-proxy.toml \
 && sed -i "s/9.9.9.9/${FALLBACK_RESOLVER}/g" dnscrypt-proxy.toml \
 && cp example-blacklist.txt blacklist.txt \
 && sed -i -E "s/\# blacklist\_file \= \'blacklist\.txt\'/blacklist_file = 'blacklist.txt'/g" dnscrypt-proxy.toml \
 && cp example-cloaking-rules.txt cloaking-rules.txt \
 && sed -i -E "s/\# cloaking\_rules/cloaking_rules/g" dnscrypt-proxy.toml \
 && chgrp -R 0 /opt/dnscrypt-proxy \
 && chmod -R g+rwx /opt/dnscrypt-proxy \
 && true

HEALTHCHECK CMD dig @127.0.0.1 reddit.com || exit 1

EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/opt/dnscrypt-proxy/dnscrypt-proxy"]
