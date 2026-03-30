# proxy

Nginx proxy configuration for forwarding requests to the OpenClaw gateway running on `http://localhost:18789`.

## Files

- `nginx.conf` - main nginx configuration
- `conf.d/openclaw-gateway.conf` - proxy definition for the OpenClaw gateway

## Behavior

The proxy listens on port `8080` and forwards all requests to `127.0.0.1:18789`.

It also forwards common proxy headers and supports HTTP/1.1 upgrade requests for WebSocket connections.

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
