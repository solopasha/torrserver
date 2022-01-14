ARG CURL_VERSION="7.82.0"
FROM node:16-alpine as front
WORKDIR /build
# hadolint ignore=DL3003,DL3018
RUN apk add --no-cache git && \
    git clone https://github.com/YouROK/TorrServer . && \
    cd web && \
    yarn install && yarn run build

FROM golang:1.18-alpine as builder
COPY --from=front /build/. /build
# hadolint ignore=DL3018
RUN apk add --no-cache git
WORKDIR /build
ARG TARGETARCH
ENV GOARCH=$TARGETARCH
# Build torrserver
# hadolint ignore=DL3003,DL3018
RUN apk add --no-cache g++ && \
    go run gen_web.go && \
    cd server && \
    CGO_ENABLED=1 go build --ldflags '-linkmode external -extldflags "-static -w -s -X"' -buildmode=pie -tags=nosqlite -trimpath -mod=readonly -modcacherw -o "torrserver" ./cmd

FROM alpine as curl
ARG CURL_VERSION
RUN apk add --no-cache build-base \
    nghttp2-dev \
    nghttp2-static \
    zlib-static \
    autoconf \
    automake \
    libtool
WORKDIR /build
RUN set -x \
    && wget -O curl.tar.gz "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz" \
    && tar xzf curl.tar.gz
WORKDIR "/build/curl-${CURL_VERSION}"
ENV CC="gcc" \
    LDFLAGS="-static" \
    PKG_CONFIG="pkg-config --static" \
    CFLAGS="-Os -flto=auto -pipe -fno-plt -fexceptions -fstack-clash-protection -fcf-protection"
RUN autoreconf -fi && \
    ./configure \
    --disable-shared \
    --enable-static \
    \
    --enable-dnsshuffle \
    --enable-werror \
    \
    --disable-cookies \
    --disable-crypto-auth \
    --disable-dict \
    --disable-file \
    --disable-ftp \
    --disable-gopher \
    --disable-imap \
    --disable-ldap \
    --disable-ldaps \
    --disable-pop3 \
    --disable-proxy \
    --disable-rtmp \
    --disable-rtsp \
    --disable-scp \
    --disable-sftp \
    --disable-smtp \
    --disable-telnet \
    --disable-tftp \
    --disable-versioned-symbols \
    --disable-doh \
    --disable-netrc \
    --disable-mqtt \
    --disable-largefile \
    --disable-manual \
    --disable-smb \
    --disable-ipv6 \
    --disable-threaded-resolver \
    --disable-tls-srp \
    --disable-doh \
    --disable-hsts \
    --without-gssapi \
    --without-libidn2 \
    --without-libpsl \
    --without-librtmp \
    --without-libssh2 \
    --without-nghttp2 \
    --without-ntlm-auth \
    --without-brotli \
    --without-ssl
RUN set -x \
    && make -j$(nproc) V=1 LDFLAGS="-static -all-static" \
    && strip --strip-all ./src/curl

FROM busybox
LABEL maintainer="solopasha"
ARG CURL_VERSION
COPY --from=builder /build/server/torrserver /bin/torrserver
COPY --from=curl /build/curl-${CURL_VERSION}/src/curl /bin/curl
ENV TORRSERVER_DIR="/torrserver"
ENV PATH="${TORRSERVER_DIR}:${PATH}"
ENV TORRSERVER_PORT="8090"
ENV GODEBUG=madvdontneed=1

WORKDIR ${TORRSERVER_DIR}
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -sS 127.0.0.1:8090/echo || exit 1
EXPOSE ${TORRSERVER_PORT}
VOLUME ${TORRSERVER_DIR}/db

CMD ["torrserver", "-d", "./db", "-t", "./db"]
