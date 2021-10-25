FROM alpine
LABEL maintainer="solopasha"

# TorrServer version
ENV TORRSERVER_VERSION="MatriX.108"

# TorrServer directory
ENV TORRSERVER_DIR="/torrserver"

# Torrserver UI port
ENV TORRSERVER_PORT="8090"

ENV GODEBUG=madvdontneed=1

# Download TorrServer binaries
RUN apk add --no-cache libc6-compat curl; \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
    x86_64) export TORRSERVER_ARCH='linux-amd64' ;; \
    x86) export TORRSERVER_ARCH='linux-386' ;; \
    aarch64) export TORRSERVER_ARCH='linux-arm64' ;; \
    armv7) export TORRSERVER_ARCH='linux-arm7' ;; \
    esac; \
    export TORRSERVER_FILE="TorrServer-${TORRSERVER_ARCH}" \
    && export TORRSERVER_RELEASE="http://releases.yourok.ru/torr/server/${TORRSERVER_FILE}" \ 
    && mkdir -p ${TORRSERVER_DIR} \
    && cd ${TORRSERVER_DIR} \
    && curl -L ${TORRSERVER_RELEASE} -o TorrServer \
    && chmod +x TorrServer \
    && apk del curl

# Expose port
EXPOSE ${TORRSERVER_PORT}

# Run TorrServer
WORKDIR ${TORRSERVER_DIR}
VOLUME ${TORRSERVER_DIR}/db
ENTRYPOINT ./TorrServer -d ./db -t ./db
