FROM --platform=linux/amd64 alpine:edge as builder

ENV SNELL_VERSION 3.0.1

ARG TARGETARCH

RUN apk update \
  && apk add --no-cache unzip upx

RUN if [ "$TARGETARCH" = "arm64" ] ; then \
    wget -O snell-server.zip https://github.com/surge-networks/snell/releases/download/v${SNELL_VERSION}/snell-server-v${SNELL_VERSION}-linux-aarch64.zip && \
    unzip snell-server.zip && \
    upx --brute snell-server && \
    mv snell-server /usr/local/bin; \
  else \
    wget -O snell-server.zip https://github.com/surge-networks/snell/releases/download/v${SNELL_VERSION}/snell-server-v${SNELL_VERSION}-linux-amd64.zip && \
    unzip snell-server.zip && \
    upx --brute snell-server && \
    mv snell-server /usr/local/bin; \
  fi

FROM minidocks/glibc:3.15

ENV SERVER_HOST 0.0.0.0
ENV SERVER_PORT 8388
ENV PSK=
ENV OBFS http
ENV ARGS=

EXPOSE ${SERVER_PORT}/tcp
EXPOSE ${SERVER_PORT}/udp

COPY --from=builder /usr/local/bin /usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
