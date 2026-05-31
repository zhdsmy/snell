# syntax=docker/dockerfile:1

FROM alpine:3.23 AS downloader

ARG TARGETARCH
ARG VERSION=5.0.1

RUN apk add --no-cache ca-certificates unzip wget \
    && case "${TARGETARCH}" in \
         amd64) SNELL_ARCH="amd64" ;; \
         arm64) SNELL_ARCH="aarch64" ;; \
         *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
       esac \
    && wget -qO /tmp/snell-server.zip "https://dl.nssurge.com/snell/snell-server-v${VERSION}-linux-${SNELL_ARCH}.zip" \
    && unzip -q /tmp/snell-server.zip -d /tmp \
    && install -m 0755 /tmp/snell-server /usr/bin/snell-server

FROM frolvlad/alpine-glibc:alpine-3.22

ARG VERSION=5.0.1

LABEL org.opencontainers.image.title="snell" \
      org.opencontainers.image.description="Docker image for Snell, a lean encrypted proxy protocol" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/zhdsmy/snell"

ENV SERVER_HOST=0.0.0.0 \
    SERVER_PORT=6333 \
    PSK="" \
    IPV6=false \
    DNS="" \
    ARGS="" \
    TZ=Asia/Shanghai

EXPOSE 6333/tcp
EXPOSE 6333/udp

COPY --from=downloader /usr/bin/snell-server /usr/bin/snell-server
COPY entrypoint.sh /entrypoint.sh

RUN apk add --no-cache libstdc++ tzdata \
    && chmod +x /entrypoint.sh

WORKDIR /

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep -f snell-server > /dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
