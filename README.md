# xray-abasthan

Xray (VLESS + WebSocket + TLS) as a web service on the Abasthan free tier.

## How it works

- Multi-stage `Dockerfile`: the Xray binary is downloaded in the build stage
  and copied into a minimal Alpine image (the official Xray image has no shell).
- `entrypoint.sh` generates `/etc/xray/config.json` from environment variables
  at container start, so no secrets are committed to this public repo.
- Xray listens on `$PORT` (default `3000`) inside the container. Abasthan
  terminates TLS on 443 and forwards WebSocket traffic to it.

## Environment variables (set in the Abasthan dashboard)

| Variable | Description |
| --- | --- |
| `UUID` | VLESS user id |
| `WS_PATH` | WebSocket path, e.g. `/vless-ws-...` |
| `PORT` | Port Xray listens on (Abasthan default: `3000`) |

## Client link format

`vless://<UUID>@<your-app>.abasthan.app:443?encryption=none&security=tls&sni=<your-app>.abasthan.app&type=ws&host=<your-app>.abasthan.app&path=<WS_PATH>#Abasthan-VLESS`
