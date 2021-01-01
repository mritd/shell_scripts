#!/usr/bin/env bash

set -e

VERSION=${VERSION:-"2.3.0"}
BUILD_DIR=$(mktemp)

function clean(){
  info "Clean build dir: ${BUILD_DIR}"
  rm -rf ${BUILD_DIR}
}

function build(){
  info "Create build dir: ${BUILD_DIR}"
  mkdir -p ${BUILD_DIR}/{etc/caddy,usr/{bin,share/caddy},lib/systemd/system}
  info "Dir tree:"
  tree ${BUILD_DIR}

  info "Install xcaddy..."
  go get -u github.com/caddyserver/xcaddy/cmd/xcaddy

  info "Building caddy..."
  xcaddy build v${VERSION} --output ${BUILD_DIR}/usr/bin/caddy \
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
}

function create_config(){
  info "Clone deb config repo: https://github.com/caddyserver/dist.git"
  git clone https://github.com/caddyserver/dist.git ${BUILD_DIR}/caddy_config

  info "Copy config..."
  cp ${BUILD_DIR}/caddy_config/init/caddy.service ${BUILD_DIR}/lib/systemd/system/caddy.service
  cp ${BUILD_DIR}/caddy_config/init/caddy-api.service ${BUILD_DIR}/lib/systemd/system/caddy-api.service
  cp ${BUILD_DIR}/caddy_config/config/Caddyfile ${BUILD_DIR}/etc/caddy/Caddyfile
  cp ${BUILD_DIR}/caddy_config/welcome/index.html ${BUILD_DIR}/usr/share/caddy/index.html
  cp -r ${BUILD_DIR}/caddy_config/scripts ${BUILD_DIR}/scripts
  rm -rf ${BUILD_DIR}/caddy_config

  info "Dir tree:"
  tree ${BUILD_DIR}
}

function package(){
  info "Create deb package..."
  (cd ${BUILD_DIR} && \
    docker run --rm -it -v `pwd`:/pkg_files -w /pkg_files -v `pwd`/dist:/dist mritd/fpm \
      fpm -s dir -t deb -n caddy2 -p /dist/caddy2_v${VERSION}.deb \
        -v ${VERSION} \
        --vendor "mritd <mritd@linux.com>" \
        --maintainer "mritd <mritd@linux.com>" \
        --after-install /pkg_files/scripts/postinstall.sh \
        --before-remove /pkg_files/scripts/preremove.sh \
        --after-remove /pkg_files/scripts/postremove.sh \
        --deb-systemd /pkg_files/lib/systemd/system/caddy.service \
        --no-deb-systemd-auto-start \
        --no-deb-systemd-restart-after-upgrade \
        etc usr lib)
  mv ${BUILD_DIR}/dist/caddy2_v${VERSION}.deb .
}

function info(){
    echo -e "\033[32mINFO: $@\033[0m"
}

function warn(){
    echo -e "\033[33mWARN: $@\033[0m"
}

function err(){
    echo -e "\033[31mERROR: $@\033[0m"
}


clean
build
create_config
package
clean
