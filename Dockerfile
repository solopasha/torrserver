FROM --platform=amd64 node:16-alpine as front
RUN apk add --no-cache git && \
    mkdir /build && cd /build && \ 
    git clone https://github.com/YouROK/TorrServer . && \ 
    cd web && \
    yarn install && yarn run build
FROM golang:1.17-alpine as builder
RUN apk add --no-cache git patch curl && \ 
    git clone https://github.com/YouROK/TorrServer /opt/src

COPY . /opt/src
COPY --from=front /build/web/build /opt/src/web/build

WORKDIR /opt/src

ARG TARGETARCH

ENV GOARCH=$TARGETARCH

# Build torrserver
RUN patch -Np1 -i 1.patch && \
    apk add --no-cache g++ && \
    go run gen_web.go && \
    cd server && \
    go clean -i -r -cache && \
    go mod tidy && \
    go build --ldflags '-linkmode external -extldflags "-static -w -s -X"' -tags=nosqlite --o "torrserver" ./cmd 

FROM busybox
ENV TORRSERVER_DIR="/torrserver"
ENV PATH="${TORRSERVER_DIR}:${PATH}"
ENV TORRSERVER_PORT="8090"

COPY --from=builder /opt/src/server/torrserver /torrserver/torrserver
WORKDIR /torrserver
EXPOSE ${TORRSERVER_PORT}

CMD ["torrserver", "-d", "./db", "-t", "./db"]
