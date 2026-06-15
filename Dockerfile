# syntax=docker/dockerfile:1

FROM alpine:3.23 AS downloader

ARG TARGETARCH
ARG VERSION=6.0.0b3
ARG SNELL_AMD64_SHA256=6db822229d9b3a05e6e37748803d41cda67b584a22a4bdab3b8e364336e4af17
ARG SNELL_ARM64_SHA256=3cffba1cb0a90cdc7d500c1a44eb166a57901843e00211a308a3c0cdc961a73c

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache ca-certificates curl unzip \
    && case "${TARGETARCH}" in \
         amd64) SNELL_ARCH="amd64"; SNELL_SHA256="${SNELL_AMD64_SHA256}" ;; \
         arm64) SNELL_ARCH="aarch64"; SNELL_SHA256="${SNELL_ARM64_SHA256}" ;; \
         *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
       esac \
    && curl -fsSL -o /tmp/snell-server.zip "https://dl.nssurge.com/snell/snell-server-v${VERSION}-linux-${SNELL_ARCH}.zip" \
    && echo "${SNELL_SHA256}  /tmp/snell-server.zip" | sha256sum -c - \
    && unzip -q /tmp/snell-server.zip -d /tmp \
    && install -m 0755 /tmp/snell-server /usr/bin/snell-server

FROM debian:bullseye-slim

ARG VERSION=6.0.0b3

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
    EGRESS_INTERFACE="" \
    MODE="" \
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
