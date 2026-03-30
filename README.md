# proxy

Nginx proxy configuration for forwarding requests to the OpenClaw gateway running on `http://localhost:18789`.

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
