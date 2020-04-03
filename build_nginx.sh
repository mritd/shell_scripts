#!/bin/bash

set -e

# Nginx and module dependencies 
NGINX_VERSION="1.17.9"
NGINX_LUA_MODULE_VERSION="0.10.15"
NGINX_NJS_VERSION="0.3.9"
HEADERS_MORE_VERSION="0.33"
LUAJIT_VERSION="2.0.2"
LUAJIT_MAIN_VERSION="2.0"
LUAJIT_LIB="/usr/local/lib"
LUAJIT_INC="/usr/local/include/luajit-${LUAJIT_MAIN_VERSION}"

PREFIX=$1

# build args
CONFIG_ARGS="\
    --prefix=${PREFIX:-/usr/local/nginx} \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-http_geoip_module=dynamic \
    --with-stream_geoip_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_perl_module=dynamic \
    --with-http_xslt_module=dynamic \
    --add-dynamic-module=/usr/src/njs-${NGINX_NJS_VERSION}/nginx \
    --add-module=/usr/src/headers-more-nginx-module-${HEADERS_MORE_VERSION} \
    --add-module=/usr/src/lua-nginx-module-${NGINX_LUA_MODULE_VERSION} \
    "

# install build dependencies
function _installdep(){
    echo -e "\033[32minstall build dependencies...\033[0m"
    apt install build-essential -y
    apt build-dep nginx -y
}

# download module dependencies
function _download(){
    echo -e "\033[32mdownload files...\033[0m"
    curl -fSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz
    curl -fSL https://github.com/openresty/lua-nginx-module/archive/v${NGINX_LUA_MODULE_VERSION}.tar.gz -o lua-nginx-module-v${NGINX_LUA_MODULE_VERSION}.tar.gz
    curl -fSL https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz -o headers-more-nginx-module-v${HEADERS_MORE_VERSION}.tar.gz 
    curl -fSL http://luajit.org/download/LuaJIT-${LUAJIT_VERSION}.tar.gz -o LuaJIT-${LUAJIT_VERSION}.tar.gz
    curl -fSL https://github.com/nginx/njs/archive/${NGINX_NJS_VERSION}.tar.gz -o njs-${NGINX_NJS_VERSION}.tar.gz
    
    tar -zxC /usr/src -f nginx.tar.gz
    tar -zxC /usr/src -f lua-nginx-module-v${NGINX_LUA_MODULE_VERSION}.tar.gz
    tar -zxC /usr/src -f headers-more-nginx-module-v${HEADERS_MORE_VERSION}.tar.gz
    tar -zxC /usr/src -f lua-nginx-module-v$NGINX_LUA_MODULE_VERSION.tar.gz
    tar -zxC /usr/src -f LuaJIT-$LUAJIT_VERSION.tar.gz
    tar -zxC /usr/src -f njs-${NGINX_NJS_VERSION}.tar.gz
    
    rm -f nginx.tar.gz
    rm -f lua-nginx-module-v${NGINX_LUA_MODULE_VERSION}.tar.gz
    rm -f headers-more-nginx-module-v${HEADERS_MORE_VERSION}.tar.gz
    rm -f nginx_upstream_check_module-v${UPSTREAM_CHECK_VERSION}.tar.gz
    rm -f LuaJIT-$LUAJIT_VERSION.tar.gz
    rm -f njs-${NGINX_NJS_VERSION}.tar.gz

}

# install Lua
function install_lua(){
    echo -e "\033[32minstall Lua $LUAJIT_VERSION ...\033[0m"
    cd /usr/src/LuaJIT-$LUAJIT_VERSION
    make -j$(getconf _NPROCESSORS_ONLN)
    make install
}    

# install nginx
function install_nginx(){
    echo -e "\033[32minstall nginx $NGINX_VERSION ...\033[0m"
    cd /usr/src/nginx-$NGINX_VERSION
    ./configure $CONFIG_ARGS --with-debug
    make -j$(getconf _NPROCESSORS_ONLN)
    make install
}

# clean
function _clean(){
    echo -e "\033[32mcleaning files...\033[0m"
    rm -rf /usr/src/*
}    

_installdep
_download
install_lua
install_nginx
_clean
