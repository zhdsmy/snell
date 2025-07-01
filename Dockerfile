FROM debian:latest as builder

ENV SNELL_VERSION v5.0.0b1

ARG TARGETARCH

RUN apk update \
  && apk add --no-cache unzip wget

RUN if [ "$TARGETARCH" = "arm64" ] ; then \
  wget -O snell-server.zip https://dl.nssurge.com/snell/snell-server-${SNELL_VERSION}-linux-aarch64.zip \
  && unzip snell-server.zip \
  && mv snell-server /usr/local/bin; \
  else \
  wget -O snell-server.zip https://dl.nssurge.com/snell/snell-server-${SNELL_VERSION}-linux-amd64.zip \
  && unzip snell-server.zip \
  && mv snell-server /usr/local/bin; \
  fi

FROM debian:latest

ENV SERVER_HOST 0.0.0.0
ENV SERVER_PORT 6333
ENV PSK=
ENV IPV6 false
ENV DNS=
ENV ARGS=
ENV TZ Asia/Shanghai

EXPOSE ${SERVER_PORT}/tcp
EXPOSE ${SERVER_PORT}/udp

COPY --from=builder /usr/local/bin /usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
