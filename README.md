# proxy

Nginx proxy configuration for forwarding requests to the OpenClaw gateway running on `http://localhost:18789`.

## Files

- `nginx.conf` - main nginx configuration
- `conf.d/openclaw-gateway.conf` - proxy definition for the OpenClaw gateway
- `conf.d/openclaw-gateway.conf.template` - Docker template for configuring the upstream target at container startup
- `Dockerfile` - container image for the proxy
- `docker-compose.yml` - Compose deployment for Ubuntu and other Docker hosts
- `ssl/` - TLS material for HTTPS (not committed); see below

## Behavior

The proxy listens on port `8080` (HTTP) and `443` (HTTPS with TLS) and forwards requests to `127.0.0.1:18789`. The OpenClaw Control UI is expected at `gateway.controlUi.basePath` (for example `/openclaw` in `openclaw.json`). Requests to `/` are redirected to `/openclaw/`; `/openclaw` and all other gateway paths are proxied as-is.

HTTPS uses HTTP/2 on port 443. It also forwards common proxy headers and supports HTTP/1.1 upgrade requests for WebSocket connections.

The Docker deployment publishes ports `8080` and `443`, mounts PEM files into `/etc/nginx/ssl/`, and by default forwards upstream to `host.docker.internal:18789`. In the provided Compose file, `host.docker.internal` is mapped to Docker's `host-gateway`, which makes the setup work on Ubuntu when the gateway is running on the host machine. You can override the upstream target with `OPENCLAW_UPSTREAM_HOST` and `OPENCLAW_UPSTREAM_PORT`.

Override certificate paths on the host with `SSL_FULLCHAIN` and `SSL_PRIVKEY` (defaults: `./ssl/fullchain.pem` and `./ssl/privkey.pem`).

Before the first `docker compose up`, create those PEM files (for example run `sh ssl/generate-selfsigned.sh` for a local self-signed pair) or point the env vars at real certificates.

For OpenClaw Control UI over HTTPS, add your public origin (for example `https://your.domain`) to `gateway.controlUi.allowedOrigins` on the gateway.

## Validate

With `ssl/fullchain.pem` and `ssl/privkey.pem` present (or after adjusting certificate paths in `conf.d/openclaw-gateway.conf`):

```bash
cd /path/to/proxy
nginx -p "$(pwd)/" -t -c nginx.conf
```

## Run

Place `fullchain.pem` and `privkey.pem` under `ssl/` (or adjust `ssl_certificate` paths in `conf.d/openclaw-gateway.conf`). Paths are relative to the nginx `-p` prefix (the project directory).

```bash
cd /path/to/proxy
nginx -p "$(pwd)/" -c nginx.conf -g 'daemon off;'
```

Binding port 443 may require elevated privileges on Linux.

## Run with Docker Compose

Create TLS files on the host first (for example `sh ssl/generate-selfsigned.sh`), then:

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
