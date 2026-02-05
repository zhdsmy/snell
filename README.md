# Snell

Docker image for [Snell](https://kb.nssurge.com/surge-knowledge-base/release-notes/snell) - A lean encrypted proxy protocol

[![Docker Hub](https://img.shields.io/docker/pulls/domizhang/snell.svg)](https://hub.docker.com/r/domizhang/snell)
[![Docker Image Size](https://img.shields.io/docker/image-size/domizhang/snell/latest)](https://hub.docker.com/r/domizhang/snell)

## 快速开始

### 使用 Docker 运行

```bash
# 使用随机生成的密码（密码会在启动时输出到日志）
docker run -d -p 6333:6333 -p 6333:6333/udp --name snell domizhang/snell:latest

# 查看生成的密码
docker logs snell

# 使用自定义密码
docker run -d -p 6333:6333 -p 6333:6333/udp \
  -e PSK="your-secure-password" \
  --name snell \
  domizhang/snell:latest

# 自定义服务器配置
docker run -d -p 6444:6444 -p 6444:6444/udp \
  -e SERVER_HOST="0.0.0.0" \
  -e SERVER_PORT="6444" \
  -e PSK="your-secure-password" \
  -e IPV6="true" \
  -e DNS="1.1.1.1,8.8.8.8" \
  --name snell \
  domizhang/snell:latest
```

### 使用 Docker Compose

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  snell:
    image: domizhang/snell:latest
    container_name: snell
    ports:
      - "6333:6333/tcp"
      - "6333:6333/udp"
    environment:
      - SERVER_HOST=0.0.0.0
      - SERVER_PORT=6333
      - PSK=your-secure-password
      - IPV6=false
      - DNS=1.1.1.1,8.8.8.8
    restart: unless-stopped
```

启动服务：

```bash
docker-compose up -d
```

## 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `SERVER_HOST` | `0.0.0.0` | 服务器监听地址 |
| `SERVER_PORT` | `6333` | 服务器监听端口（同时支持 TCP/UDP） |
| `PSK` | 随机生成 | 连接密码，如果不设置将自动生成并输出到日志 |
| `IPV6` | `false` | 是否启用 IPv6 支持 |
| `DNS` | 空 | DNS 服务器地址，多个用逗号分隔 |
| `ARGS` | 空 | 额外的命令行参数 |

## 支持的架构

- `linux/amd64`
- `linux/arm64`

## 镜像标签

- `latest` - 最新的 master 分支构建
- `x.y.z` - 特定版本号（如 `5.0.1`）
- `x.y` - 主次版本号（如 `5.0`）

## 使用示例

### Surge 客户端配置

在 Surge 配置文件中添加代理：

```ini
[Proxy]
Proxy = snell, [SERVER_IP], [SERVER_PORT], psk=[PSK], version=5
```

## 安全建议

1. **强烈建议**在生产环境中使用 `PSK` 环境变量设置强密码
2. 不要在公网直接暴露服务，建议配合防火墙或反向代理使用
3. 定期更新到最新版本以获取安全补丁
4. 建议使用非标准端口以减少扫描风险

## 许可证

本项目遵循 Snell 的许可证。详见 [Snell 文档](https://kb.nssurge.com/surge-knowledge-base/release-notes/snell)。

## 相关链接

- [Snell 文档](https://kb.nssurge.com/surge-knowledge-base/release-notes/snell)
- [Docker Hub](https://hub.docker.com/r/domizhang/snell)
