FROM ubuntu:focal as builder

ENV SNELL_VERSION 4.0.0

ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y unzip wget

RUN if [ "$TARGETARCH" = "arm64" ] ; then \
  wget -O snell-server.zip https://dl.nssurge.com/snell/snell-server-v${SNELL_VERSION}-linux-aarch64.zip && \
  unzip snell-server.zip && \
  mv snell-server /usr/local/bin; \
  else \
  wget -O snell-server.zip https://dl.nssurge.com/snell/snell-server-v${SNELL_VERSION}-linux-amd64.zip && \
  unzip snell-server.zip && \
  mv snell-server /usr/local/bin; \
  fi

FROM ubuntu:focal

ENV SERVER_HOST 0.0.0.0
ENV SERVER_PORT 8888
ENV PSK=
ENV IPV6 false
ENV ARGS=

EXPOSE ${SERVER_PORT}/tcp
EXPOSE ${SERVER_PORT}/udp

COPY --from=builder /usr/local/bin /usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
