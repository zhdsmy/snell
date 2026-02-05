#!/bin/sh
set -ex

# 打印启动信息
echo "=========================================="
echo "Starting snell-server"
echo "=========================================="

# 设置环境变量默认值
SERVER_HOST=${SERVER_HOST:-0.0.0.0}
SERVER_PORT=${SERVER_PORT:-6333}
IPV6=${IPV6:-false}

# 如果密码环境变量不存在，生成随机密码
if [ -z "$PSK" ]; then
    PSK=$(hexdump -n 16 -e '4/4 "%08x" 1 "\n"' /dev/urandom)
    echo "⚠️  No PSK provided, generated random password:"
    echo "🔑 Password: $PSK"
    echo "⚠️  Please save this password for client connections!"
else
    echo "✓ Using provided PSK"
fi

# 创建配置文件
cat > snell.conf <<EOF
[snell-server]
listen = ${SERVER_HOST}:${SERVER_PORT}
psk = ${PSK}
ipv6 = ${IPV6}
EOF

# 如果设置了DNS，添加到配置
if [ -n "$DNS" ]; then
    echo "dns = ${DNS}" >> snell.conf
fi

echo "📡 Server Host: $SERVER_HOST"
echo "🔌 Server Port: $SERVER_PORT"
echo "🌐 IPv6 Support: $IPV6"
if [ -n "$DNS" ]; then
    echo "📡 DNS Server: $DNS"
fi
echo "=========================================="

# 显示配置文件内容
echo "📄 Configuration file:"
cat snell.conf
echo "=========================================="

# 运行snell-server并传递参数
exec /usr/bin/snell-server -c snell.conf ${ARGS}
