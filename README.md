# proxy

Nginx reverse proxy for the OpenClaw **Control UI** only: requests under `/openclaw` are forwarded to the gateway (`gateway.controlUi.basePath` in `openclaw.json`). Any other path returns **404** (use a different listener or direct port `18789` for HTTP API / chat endpoints).

`GET /` without an `Upgrade` header redirects to `/openclaw/`.

### Control UI WebSocket URL

In the Control UI settings, set **WebSocket URL** to **`wss://<your-host>/openclaw`** (same path as `basePath`, over HTTPS on port 443). Example: `wss://promai.work/openclaw`. That matches what nginx proxies and avoids handshake issues. Newer OpenClaw builds also default the WebSocket URL from `basePath` ([openclaw#30228](https://github.com/openclaw/openclaw/pull/30228)).

The proxy **does not override** `Origin`; include **`https://<your-host>`** in `gateway.controlUi.allowedOrigins`.

**Fallback:** `wss://<host>/` (root path) is proxied via `@openclaw_ws_root` for older clients that omit `basePath` in the WebSocket URL. Prefer **`wss://<host>/openclaw`** when configuring manually.

### Device pairing (“pairing required”)

The Control UI treats new browsers as **devices** that must be approved once on the **machine where the OpenClaw gateway runs** (not on the nginx host unless it is the same machine).

1. On the gateway host, run **`openclaw devices list`** and note pending requests.
2. Approve with **`openclaw devices approve <requestId>`** (use the id from the list).

**Phone or another PC:** On the gateway, run **`openclaw dashboard --no-open`**, copy the full URL it prints (including **`#token=...`**), open that URL on the device so the UI can authenticate without going through the pairing queue first.

After approval, reload the Control UI at **`https://<your-host>/openclaw/`** if it still shows the pairing screen.

## TLS and self-signed certificates

Helper script: `ssl/generate-selfsigned.sh`. HTTPS on port 443 expects `ssl/fullchain.pem` and `ssl/privkey.pem` on the host (Compose bind-mounts them into the container). If those files are missing, create them with a real CA-issued certificate, or for **local development** use the helper script:

```bash
cd /path/to/proxy
sh ssl/generate-selfsigned.sh
```

The script runs `openssl req` to write **both** PEM files next to itself under `ssl/`. It uses `-subj "/CN=localhost"` (no SANs); browsers will show a certificate warning until you trust the cert or replace it with a hostname-valid certificate for production.

Requirements: `openssl` on your `PATH`. Run the script once before `nginx -t` or `docker compose up` when the default PEM paths are empty.

## Validate

With `ssl/fullchain.pem` and `ssl/privkey.pem` present (or after adjusting certificate paths in `conf.d/openclaw-gateway.conf`):

```bash
cd /path/to/proxy
nginx -p "$(pwd)/" -t -c nginx.conf
```

## Run

Place `fullchain.pem` and `privkey.pem` under `ssl/` (see [TLS and self-signed certificates](#tls-and-self-signed-certificates), or adjust `ssl_certificate` paths in `conf.d/openclaw-gateway.conf`). Paths are relative to the nginx `-p` prefix (the project directory).

```bash
cd /path/to/proxy
nginx -p "$(pwd)/" -c nginx.conf -g 'daemon off;'
```

Binding port 443 may require elevated privileges on Linux.

## Run with Docker Compose

Create TLS files on the host first (see [TLS and self-signed certificates](#tls-and-self-signed-certificates)), then:

```bash
cd /path/to/proxy
docker compose up --build -d
```

### Override the upstream target

```bash
OPENCLAW_UPSTREAM_HOST=openclaw-gateway \
OPENCLAW_UPSTREAM_PORT=18789 \
docker compose up --build -d
```

### Validate the container configuration

```bash
cd /path/to/proxy
docker compose run --rm proxy nginx -t
```
