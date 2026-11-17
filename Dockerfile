# syntax=docker/dockerfile:1
# Multi-stage build: fetch the Xray binary, then copy it into a minimal
# Alpine image (the official Xray image ships no shell, Alpine does).
# Xray listens on $PORT (default 3000) inside the container; Abasthan
# terminates TLS on 443 and forwards plain HTTP/WebSocket traffic to it.

FROM alpine:3.20 AS downloader
RUN apk add --no-cache curl unzip \
 && curl -fsSL -o /tmp/xray.zip \
      https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
 && unzip -o /tmp/xray.zip -d /tmp/xray

FROM alpine:3.20
RUN apk add --no-cache ca-certificates curl unzip
COPY --from=downloader /tmp/xray/xray /usr/local/bin/xray
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/xray /entrypoint.sh
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
