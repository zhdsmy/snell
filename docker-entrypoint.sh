#!/bin/sh

launch() {
  if [ -z "$PSK" ]; then
    PSK=`hexdump -n 16 -e '4/4 "%08x" 1 "\n"' /dev/urandom`
  fi

  if [ -z "$DNS" ]; then
  cat > snell.conf <<EOF
[snell-server]
listen = ${SERVER_HOST}:${SERVER_PORT}
psk = ${PSK}
ipv6 = ${IPV6}
EOF
  else
  cat > snell.conf <<EOF
[snell-server]
listen = ${SERVER_HOST}:${SERVER_PORT}
psk = ${PSK}
ipv6 = ${IPV6}
dns = ${DNS}
EOF
  fi

  cat snell.conf
  snell-server \
    -c snell.conf \
    ${ARGS}
}


if [ -z "$@" ]; then
  launch
else
  exec "$@"
fi
