# syntax=docker/dockerfile:1

FROM alpine:3.23 AS downloader

ARG TARGETARCH
ARG VERSION=6.0.0b1
ARG SNELL_AMD64_SHA256=3592aaa807c2dfd09e39d4574ac9ec17ed8dba57571c6dbf2c7f44bbe219e2c7
ARG SNELL_ARM64_SHA256=f18ed9a4f9ea3af42fc616fe164402a46b2c01811affcc5382e681d217a6d938

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache ca-certificates unzip wget \
    && case "${TARGETARCH}" in \
         amd64) SNELL_ARCH="amd64"; SNELL_SHA256="${SNELL_AMD64_SHA256}" ;; \
         arm64) SNELL_ARCH="aarch64"; SNELL_SHA256="${SNELL_ARM64_SHA256}" ;; \
         *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
       esac \
    && wget -qO /tmp/snell-server.zip "https://dl.nssurge.com/snell/snell-server-v${VERSION}-linux-${SNELL_ARCH}.zip" \
    && echo "${SNELL_SHA256}  /tmp/snell-server.zip" | sha256sum -c - \
    && unzip -q /tmp/snell-server.zip -d /tmp \
    && install -m 0755 /tmp/snell-server /usr/bin/snell-server

FROM debian:bullseye-slim

ARG VERSION=6.0.0b1

LABEL org.opencontainers.image.title="snell" \
      org.opencontainers.image.description="Docker image for Snell, a lean encrypted proxy protocol" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/zhdsmy/snell"

ENV SERVER_HOST=0.0.0.0 \
    SERVER_PORT=6333 \
    PSK="" \
    IPV6=false \
    DNS="" \
    DNS_IP_PREFERENCE="" \
    ARGS="" \
    TZ=Asia/Shanghai

EXPOSE 6333/tcp
EXPOSE 6333/udp

COPY --from=downloader /usr/bin/snell-server /usr/bin/snell-server
COPY entrypoint.sh /entrypoint.sh

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        libc-ares2 \
        libssl1.1 \
        libstdc++6 \
        libsodium23 \
        libuv1 \
        procps \
        tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /entrypoint.sh

WORKDIR /

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep -f snell-server > /dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
