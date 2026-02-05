FROM alpine:latest AS builder

ARG TARGETARCH
ARG VERSION=v5.0.1

# 安装依赖并下载snell二进制文件
RUN apk update \
    && apk add --no-cache unzip wget ca-certificates \
    && rm -rf /var/cache/apk/* \
    && if [ "$TARGETARCH" = "arm64" ] ; then \
         ARCH="aarch64"; \
       else \
         ARCH="amd64"; \
       fi \
    && wget -O snell-server.zip https://dl.nssurge.com/snell/snell-server-${VERSION}-linux-${ARCH}.zip \
    && unzip -q snell-server.zip \
    && mv snell-server /usr/bin/snell-server \
    && chmod +x /usr/bin/snell-server \
    && rm -rf /tmp/* snell-server.zip

FROM frolvlad/alpine-glibc:latest

ARG VERSION=v5.0.1

LABEL maintainer="domizhang" \
      description="Docker image for snell - A lean encrypted proxy protocol " \
      version="${VERSION}"

# 设置环境变量默认值
ENV SERVER_HOST=0.0.0.0 \
    SERVER_PORT=6333 \
    PSK="" \
    IPV6=false \
    DNS="" \
    ARGS="" \
    TZ=Asia/Shanghai

# 暴露默认端口
EXPOSE ${SERVER_PORT}/tcp
EXPOSE ${SERVER_PORT}/udp

# 复制二进制文件和启动脚本
COPY --from=builder /usr/bin/snell-server /usr/bin/snell-server
COPY entrypoint.sh /entrypoint.sh

# 安装依赖并清理缓存
RUN apk update \
    && apk add --no-cache hexdump tzdata libstdc++ \
    && rm -rf /var/cache/apk/* \
    && chmod +x /entrypoint.sh

WORKDIR /

# 健康检查（动态检测进程是否存在）
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep -f snell-server > /dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
