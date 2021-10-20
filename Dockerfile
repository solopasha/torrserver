FROM alpine
LABEL maintainer="solopasha"

# TorrServer version
ENV TORRSERVER_VERSION="MatriX.108"

# TorrServer architecture
ENV TORRSERVER_ARCH="linux-amd64"
ENV TORRSERVER_FILE="TorrServer-${TORRSERVER_ARCH}"

# TorrServer release info
#ENV TORRSERVER_RELEASE="https://github.com/YouROK/TorrServer/releases/download/${TORRSERVER_VERSION}/${TORRSERVER_FILE}" # https://t.me/TorrServe/225610

# TorrServer directory
ENV TORRSERVER_DIR="/torrserver"

# Torrserver UI port
ENV TORRSERVER_PORT="8090"

ENV GODEBUG=madvdontneed=1

COPY ./torrserver ${TORRSERVER_DIR}
# Download TorrServer binaries
RUN apk add --no-cache libc6-compat

# Expose port
EXPOSE ${TORRSERVER_PORT}

# Run TorrServer
WORKDIR ${TORRSERVER_DIR}
VOLUME ${TORRSERVER_DIR}/db
ENTRYPOINT ./${TORRSERVER_FILE} -d ./db -t ./db
