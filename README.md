# Snell

Docker image for [Snell](https://kb.nssurge.com/surge-knowledge-base/release-notes/snell), a lean encrypted proxy protocol.

[![Docker Pulls](https://img.shields.io/docker/pulls/domizhang/snell.svg)](https://hub.docker.com/r/domizhang/snell)
[![Docker Image Size](https://img.shields.io/docker/image-size/domizhang/snell/latest)](https://hub.docker.com/r/domizhang/snell)

## Included version

- Snell: `5.0.1`
- Runtime base image: `frolvlad/alpine-glibc:alpine-3.22`
- Release artifacts are verified with pinned SHA256 checksums during build.

## Supported platforms

- `linux/amd64`
- `linux/arm64`

## Tags

- `latest`: latest build from the default branch
- `5.0.1`: current Snell version build
- `5.0`: major/minor tag for versioned releases

## Quick start

Run with a generated password:

```bash
docker run -d \
  --name snell \
  -p 6333:6333/tcp \
  -p 6333:6333/udp \
  domizhang/snell:latest
```

Read the generated password from logs:

```bash
docker logs snell
```

Run with a fixed password:

```bash
docker run -d \
  --name snell \
  -p 6333:6333/tcp \
  -p 6333:6333/udp \
  -e PSK="your-secure-password" \
  domizhang/snell:latest
```

Customize listener, IPv6, DNS, and extra Snell arguments:

```bash
docker run -d \
  --name snell \
  -p 6444:6444/tcp \
  -p 6444:6444/udp \
  -e SERVER_HOST="0.0.0.0" \
  -e SERVER_PORT="6444" \
  -e PSK="your-secure-password" \
  -e IPV6="true" \
  -e DNS="1.1.1.1,8.8.8.8" \
  domizhang/snell:latest \
  --reuse-port
```

## Docker Compose

```yaml
services:
  snell:
    image: domizhang/snell:latest
    container_name: snell
    restart: unless-stopped
    ports:
      - "6333:6333/tcp"
      - "6333:6333/udp"
    environment:
      SERVER_HOST: 0.0.0.0
      SERVER_PORT: "6333"
      PSK: your-secure-password
      IPV6: "false"
      DNS: 1.1.1.1,8.8.8.8
```

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `SERVER_HOST` | `0.0.0.0` | Server listen host |
| `SERVER_PORT` | `6333` | Server listen port for TCP and UDP |
| `PSK` | generated | Pre-shared key. If empty, a random key is generated and printed once at startup |
| `IPV6` | `false` | Enable IPv6 support |
| `DNS` | empty | DNS servers, comma-separated |
| `ARGS` | empty | Deprecated compatibility option. Prefer passing extra arguments after the image name |
| `CONFIG_FILE` | `/tmp/snell.conf` | Generated config file path inside the container |

## Surge client example

```ini
[Proxy]
Proxy = snell, SERVER_IP, 6333, psk=YOUR_PSK, version=5
```

## Security notes

- Use a strong explicit `PSK` in production.
- The generated `PSK` is printed to container logs so the client can be configured. Treat logs as sensitive.
- Provided `PSK` values are not printed, and the generated config path is logged with the key hidden.
- Do not expose the service publicly without firewall rules or an explicit access policy.

## Build locally

```bash
docker build \
  --build-arg VERSION=5.0.1 \
  -t domizhang/snell:local .
```

## Update policy

The Snell version is pinned in `Dockerfile` and `.github/workflows/main.yml`. To update:

1. Check the upstream [Snell release notes](https://kb.nssurge.com/surge-knowledge-base/release-notes/snell).
2. Update `VERSION` / `DEFAULT_VERSION` and the per-architecture SHA256 build arguments.
3. Build and test the image.
4. Tag the repository as `vX.Y.Z` to publish versioned tags.

## License

This repository only builds a Docker image. Snell is distributed under its upstream license.
