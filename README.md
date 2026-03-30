# proxy

Nginx proxy configuration for forwarding requests to the OpenClaw gateway running on `http://localhost:18789`.

## Files

- `nginx.conf` - main nginx configuration
- `conf.d/openclaw-gateway.conf` - proxy definition for the OpenClaw gateway
- `conf.d/openclaw-gateway.conf.template` - Docker template for configuring the upstream target at container startup
- `Dockerfile` - container image for the proxy
- `docker-compose.yml` - Compose deployment for Ubuntu and other Docker hosts

## Behavior

The proxy listens on port `8080` and forwards all requests to `127.0.0.1:18789`.

It also forwards common proxy headers and supports HTTP/1.1 upgrade requests for WebSocket connections.

The Docker deployment publishes port `8080` and, by default, forwards to `host.docker.internal:18789`. In the provided Compose file, `host.docker.internal` is mapped to Docker's `host-gateway`, which makes the setup work on Ubuntu when the gateway is running on the host machine. You can override the upstream target with `OPENCLAW_UPSTREAM_HOST` and `OPENCLAW_UPSTREAM_PORT`.

## Validate

```bash
cd /path/to/proxy
nginx -p "$(pwd)/" -t -c nginx.conf
```

## Run

```bash
cd /path/to/proxy
nginx -p "$(pwd)/" -c nginx.conf -g 'daemon off;'
```

## Run with Docker Compose

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
