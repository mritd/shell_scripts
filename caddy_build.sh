#!/usr/bin/env bash

go get -u github.com/caddyserver/xcaddy/cmd/xcaddy

xcaddy build \
  --with github.com/abiosoft/caddy-exec \
  --with github.com/caddy-dns/cloudflare \
  --with github.com/caddy-dns/dnspod \
  --with github.com/caddy-dns/duckdns \
  --with github.com/caddy-dns/gandi \
  --with github.com/caddy-dns/route53 \
  --with github.com/greenpau/caddy-auth-jwt \
  --with github.com/greenpau/caddy-auth-portal \
  --with github.com/greenpau/caddy-trace \
  --with github.com/hairyhenderson/caddy-teapot-module \
  --with github.com/kirsch33/realip \
  --with github.com/porech/caddy-maxmind-geolocation \
  --with github.com/mholt/caddy-webdav
