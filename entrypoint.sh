#!/bin/sh
set -eu

SERVER_HOST=${SERVER_HOST:-0.0.0.0}
SERVER_PORT=${SERVER_PORT:-6333}
IPV6=${IPV6:-false}
DNS_IP_PREFERENCE=${DNS_IP_PREFERENCE:-}
EGRESS_INTERFACE=${EGRESS_INTERFACE:-}
MODE=${MODE:-}
CONFIG_FILE=${CONFIG_FILE:-/tmp/snell.conf}

echo "=========================================="
echo "Starting snell-server"
echo "=========================================="

if [ -z "${PSK:-}" ]; then
    PSK=$(hexdump -n 16 -e '4/4 "%08x" 1 "\n"' /dev/urandom)
    echo "No PSK provided. Generated random password:"
    echo "Password: ${PSK}"
    echo "Save this password for client connections."
else
    echo "Using provided PSK."
fi

umask 077
cat > "${CONFIG_FILE}" <<EOF
[snell-server]
listen = ${SERVER_HOST}:${SERVER_PORT}
psk = ${PSK}
ipv6 = ${IPV6}
EOF

if [ -n "${DNS:-}" ]; then
    echo "dns = ${DNS}" >> "${CONFIG_FILE}"
fi

if [ -n "${DNS_IP_PREFERENCE:-}" ]; then
    echo "dns-ip-preference = ${DNS_IP_PREFERENCE}" >> "${CONFIG_FILE}"
fi

if [ -n "${EGRESS_INTERFACE:-}" ]; then
    echo "egress-interface = ${EGRESS_INTERFACE}" >> "${CONFIG_FILE}"
fi

if [ -n "${MODE:-}" ]; then
    echo "mode = ${MODE}" >> "${CONFIG_FILE}"
fi

echo "Server Host: ${SERVER_HOST}"
echo "Server Port: ${SERVER_PORT}"
echo "IPv6 Support: ${IPV6}"
if [ -n "${DNS:-}" ]; then
    echo "DNS Server: ${DNS}"
fi
if [ -n "${DNS_IP_PREFERENCE:-}" ]; then
    echo "DNS IP Preference: ${DNS_IP_PREFERENCE}"
fi
if [ -n "${EGRESS_INTERFACE:-}" ]; then
    echo "Egress Interface: ${EGRESS_INTERFACE}"
fi
if [ -n "${MODE:-}" ]; then
    echo "Mode: ${MODE}"
fi
echo "Configuration: ${CONFIG_FILE} (psk hidden)"
echo "=========================================="

if [ -n "${ARGS:-}" ]; then
    echo "ARGS is deprecated. Pass extra snell-server options after the image name instead."
    set -f
    # shellcheck disable=SC2086
    set -- ${ARGS} "$@"
    set +f
fi

exec /usr/bin/snell-server -c "${CONFIG_FILE}" "$@"
