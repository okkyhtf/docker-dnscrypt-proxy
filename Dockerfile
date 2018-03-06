FROM arm32v6/alpine:3.7
LABEL maintainer="Okky Hendriansyah <okky.htf@gmail.com>"

ENV LOCAL_PORT=5353 \
    DNSCRYPT_PROXY_VERSION=2.0.6 \
    FALLBACK_RESOLVER=203.142.82.222

RUN set -xe \
 && apk add --no-cache curl tini tzdata \
 && curl -LO https://github.com/jedisct1/dnscrypt-proxy/releases/download/${DNSCRYPT_PROXY_VERSION}/dnscrypt-proxy-linux_arm-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && mkdir -p /opt \
 && mv dnscrypt-proxy-linux_arm-${DNSCRYPT_PROXY_VERSION}.tar.gz /opt \
 && cd /opt \
 && tar xvvzpf dnscrypt-proxy-linux_arm-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && rm dnscrypt-proxy-linux_arm-${DNSCRYPT_PROXY_VERSION}.tar.gz \
 && mv linux-arm dnscrypt-proxy \
 && cd dnscrypt-proxy \
 && cp example-dnscrypt-proxy.toml dnscrypt-proxy.toml \
 && sed -i -E "s/\'127\.0\.0\.1\:53\'\, \'\[\:\:1\]\:53\'/'0.0.0.0:${LOCAL_PORT}'/g" dnscrypt-proxy.toml \
 && sed -i "s/9.9.9.9/${FALLBACK_RESOLVER}/g" dnscrypt-proxy.toml \
 && cp example-blacklist.txt blacklist.txt \
 && sed -i -E "s/\# blacklist\_file \= \'blacklist\.txt\'/blacklist_file = 'blacklist.txt'/g" dnscrypt-proxy.toml \
 && cp example-cloaking-rules.txt cloaking-rules.txt \
 && sed -i -E "s/\# cloaking\_rules/cloaking_rules/g" dnscrypt-proxy.toml

EXPOSE $LOCAL_PORT/tcp $LOCAL_PORT/udp
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/opt/dnscrypt-proxy/dnscrypt-proxy"]
