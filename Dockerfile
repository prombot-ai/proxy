FROM nginx:1.27-alpine

RUN rm -f /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/openclaw-gateway.conf.template /etc/nginx/templates/openclaw-gateway.conf.template

ENV OPENCLAW_UPSTREAM_HOST=host.docker.internal
ENV OPENCLAW_UPSTREAM_PORT=18789

EXPOSE 8080 443
