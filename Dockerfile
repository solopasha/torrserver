FROM --platform=linux/amd64 node:19-alpine as front
WORKDIR /build
# hadolint ignore=DL3003,DL3018
RUN apk add --no-cache git && \
    git clone https://github.com/YouROK/TorrServer . && \
    cd web && \
    yarn install && \
    sed '10 i const crypto = require("crypto");\nconst crypto_orig_createHash = crypto.createHash;\ncrypto.createHash = algorithm => crypto_orig_createHash(algorithm == "md4" ? "sha256" : algorithm);' \
    -i node_modules/react-scripts/config/webpack.config.js && \
    yarn run build

FROM golang:1.21-alpine as builder
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
    CGO_ENABLED=1 go build -ldflags '-w -s' -buildmode=pie -tags=nosqlite -trimpath -mod=readonly -modcacherw -o "torrserver" ./cmd

FROM mwader/static-ffmpeg as ffmpeg

FROM ghcr.io/linuxserver/baseimage-alpine:3.18
LABEL maintainer="solopasha"
COPY --from=ffmpeg /ffprobe /usr/bin/
COPY --from=builder /build/server/torrserver /usr/bin/torrserver
RUN apk add --no-cache curl libstdc++ tzdata
ENV TORRSERVER_DIR="/torrserver"
ENV TORRSERVER_PORT="8090"
ENV GODEBUG=madvdontneed=1

WORKDIR ${TORRSERVER_DIR}
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -sS 127.0.0.1:${TORRSERVER_PORT}/echo || exit 1
EXPOSE ${TORRSERVER_PORT}
VOLUME ${TORRSERVER_DIR}/db

COPY root/ /
