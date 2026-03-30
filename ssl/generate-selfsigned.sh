#!/bin/sh
# Writes ./fullchain.pem and ./privkey.pem next to this script (for docker-compose bind mounts).
set -e
cd "$(dirname "$0")"
openssl req -x509 -nodes -newkey rsa:2048 -days 825 \
  -keyout privkey.pem -out fullchain.pem \
  -subj "/CN=localhost"
