#!/bin/sh
# Generate the Xray config from environment variables at container start,
# so secrets never live in this public repository.
# Required env vars (set in the Abasthan dashboard):
#   UUID    - VLESS user id
#   WS_PATH - WebSocket path, e.g. /vless-ws-k7d2q9x4
# Optional:
#   PORT    - port Xray listens on (Abasthan default: 3000)
set -eu

PORT="${PORT:-3000}"

if [ -z "${UUID:-}" ]; then
  echo "error: UUID env var is not set" >&2
  exit 1
fi
if [ -z "${WS_PATH:-}" ]; then
  echo "error: WS_PATH env var is not set" >&2
  exit 1
fi

# Fallback for builders that do not use the Dockerfile: fetch xray if missing.
if ! command -v xray >/dev/null 2>&1 && [ ! -x /usr/local/bin/xray ]; then
  echo "xray binary not found, downloading latest release..."
  mkdir -p /tmp/xray-bin
  curl -fsSL -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
  unzip -o /tmp/xray.zip -d /tmp/xray-bin
  export PATH="/tmp/xray-bin:$PATH"
fi

mkdir -p /etc/xray
cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": ${PORT},
      "listen": "0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "${UUID}", "flow": "" }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "${WS_PATH}" }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "blocked" }
  ]
}
EOF

exec xray run -c /etc/xray/config.json
