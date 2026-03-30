# proxy

Nginx proxy configuration for forwarding requests to the OpenClaw gateway running on `http://localhost:18789`.

## Files

- `/home/runner/work/proxy/proxy/nginx.conf` - main nginx configuration
- `/home/runner/work/proxy/proxy/conf.d/openclaw-gateway.conf` - proxy definition for the OpenClaw gateway

## Behavior

The proxy listens on port `80` and forwards all requests to `127.0.0.1:18789`.

It also forwards common proxy headers and supports HTTP/1.1 upgrade requests for websocket-style connections.

## Validate

```bash
nginx -t -c /home/runner/work/proxy/proxy/nginx.conf
```

## Run

```bash
nginx -c /home/runner/work/proxy/proxy/nginx.conf -g 'daemon off;'
```
