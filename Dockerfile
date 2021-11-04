FROM alpine
LABEL maintainer="solopasha"

# TorrServer version
ENV TORRSERVER_VERSION="MatriX.109"

# TorrServer directory
ENV TORRSERVER_DIR="/torrserver"

# Torrserver UI port
ENV TORRSERVER_PORT="8090"

ENV GODEBUG=madvdontneed=1
WORKDIR ${TORRSERVER_DIR}
ENV PATH="${TORRSERVER_DIR}:${PATH}"

# Download TorrServer binaries
RUN apk add --no-cache libc6-compat; \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
    x86_64) export TORRSERVER_ARCH='linux-amd64' ;; \
    x86) export TORRSERVER_ARCH='linux-386' ;; \
    aarch64) export TORRSERVER_ARCH='linux-arm64' ;; \
    armv7) export TORRSERVER_ARCH='linux-arm7' ;; \
    esac; \
    export TORRSERVER_FILE="TorrServer-${TORRSERVER_ARCH}" && \
    export TORRSERVER_RELEASE="https://github.com/YouROK/TorrServer/releases/download/${TORRSERVER_VERSION}/${TORRSERVER_FILE}" && \
    wget -q ${TORRSERVER_RELEASE} -O TorrServer && \
    chmod +x TorrServer

# Expose port
EXPOSE ${TORRSERVER_PORT}

# Run TorrServer
VOLUME ${TORRSERVER_DIR}/db
ENTRYPOINT ["TorrServer", "-d", "./db", "-t", "./db"]
