FROM ghcr.io/linuxserver/baseimage-alpine:3.18
LABEL maintainer="solopasha"

# TorrServer directory
ENV TORRSERVER_DIR="/torrserver"

# Torrserver UI port
ENV TORRSERVER_PORT="8090"

ENV GODEBUG=madvdontneed=1
ENV PATH="${TORRSERVER_DIR}:${PATH}"

WORKDIR ${TORRSERVER_DIR}
# Download TorrServer binaries
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk add --no-cache libc6-compat curl libstdc++ jq; \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
    x86_64) export TORRSERVER_ARCH='linux-amd64' ;; \
    x86) export TORRSERVER_ARCH='linux-386' ;; \
    aarch64) export TORRSERVER_ARCH='linux-arm64' ;; \
    armv7) export TORRSERVER_ARCH='linux-arm7' ;; \
    esac; \
    version="$(curl -s "https://api.github.com/repos/YouROK/TorrServer/releases/latest" | jq -r '.tag_name')" && \
    export TORRSERVER_FILE="TorrServer-${TORRSERVER_ARCH}" && \
    export TORRSERVER_RELEASE="https://github.com/YouROK/TorrServer/releases/download/${version}/${TORRSERVER_FILE}" && \
    curl -sLS "${TORRSERVER_RELEASE}" -o TorrServer && \
    chmod +x TorrServer

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -sS 127.0.0.1:${TORRSERVER_PORT}/echo || exit 1

# Expose port
EXPOSE ${TORRSERVER_PORT}

# Run TorrServer
VOLUME ${TORRSERVER_DIR}/db

COPY root/ /
