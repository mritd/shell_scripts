#!/bin/bash

# Nginx and module dependencies 
NGINX_VERSION="1.11.6"
NGINX_LUA_MODULE_VERSION="0.10.7"
OPENSSL_VERSION="1.0.1t"
HEADERS_MORE_VERSION="0.32"
UPSTREAM_CHECK_VERSION="0.3.0"
DEVEL_KIT_VERSION="0.3.0"
LUAJIT_VERSION="2.0.4"
LUAJIT_MAIN_VERSION="2.0"
LUAJIT_LIB="/usr/local/lib"
LUAJIT_INC="/usr/local/include/luajit-$LUAJIT_MAIN_VERSION"

PREFIX=$1

# build args
CONFIG_ARGS="\
    --prefix=${PREFIX:-/usr/local/nginx} \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_perl_module=dynamic \
    --with-threads \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-http_v2_module \
    --with-openssl=/usr/src/openssl-${OPENSSL_VERSION} \
    --add-module=/usr/src/headers-more-nginx-module-${HEADERS_MORE_VERSION} \
    --add-module=/usr/src/nginx_upstream_check_module-${UPSTREAM_CHECK_VERSION} \
    --add-module=/usr/src/ngx_devel_kit-${DEVEL_KIT_VERSION} \
    --add-module=/usr/src/lua-nginx-module-${NGINX_LUA_MODULE_VERSION} \
    --http-client-body-temp-path=/tmp/nginx/client_body_temp \
    --http-proxy-temp-path=/tmp/nginx/proxy_temp \
    --http-fastcgi-temp-path=/tmp/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/tmp/nginx/uwsgi_temp \
    --http-scgi-temp-path=/tmp/nginx/scgi_temp \
    "

# install build dependencies
function _installdep(){
    echo -e "\033[32minstall build dependencies...\033[0m"
    yum install gcc glibc glibc-devel make openssl \
        openssl-devel pcre pcre-devel zlib zlib-devel \
        kernel-devel curl gnupg libxslt libxslt-devel \
        gd-devel geoip-devel perl-devel perl-ExtUtils-Embed \
        lua lua-devel -y
}

# download module dependencies
function _downloadfiles(){
    echo -e "\033[32mdownload module dependencies...\033[0m"
    curl -fSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz
    curl -fSL https://github.com/openresty/lua-nginx-module/archive/v${NGINX_LUA_MODULE_VERSION}.tar.gz -o lua-nginx-module-v${NGINX_LUA_MODULE_VERSION}.tar.gz
    curl -fSL https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz -o openssl-${OPENSSL_VERSION}.tar.gz
    curl -fSL https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz -o headers-more-nginx-module-v${HEADERS_MORE_VERSION}.tar.gz 
    curl -fSL https://github.com/yaoweibin/nginx_upstream_check_module/archive/v${UPSTREAM_CHECK_VERSION}.tar.gz -o nginx_upstream_check_module-v${UPSTREAM_CHECK_VERSION}.tar.gz
    curl -fSL https://github.com/simpl/ngx_devel_kit/archive/v${DEVEL_KIT_VERSION}.tar.gz -o ngx_devel_kit-v${DEVEL_KIT_VERSION}.tar.gz
    curl -fSL http://luajit.org/download/LuaJIT-$LUAJIT_VERSION.tar.gz -o LuaJIT-$LUAJIT_VERSION.tar.gz
    
    tar -zxC /usr/src -f nginx.tar.gz
    tar -zxC /usr/src -f lua-nginx-module-v${NGINX_LUA_MODULE_VERSION}.tar.gz
    tar -zxC /usr/src -f openssl-${OPENSSL_VERSION}.tar.gz
    tar -zxC /usr/src -f headers-more-nginx-module-v${HEADERS_MORE_VERSION}.tar.gz
    tar -zxC /usr/src -f nginx_upstream_check_module-v${UPSTREAM_CHECK_VERSION}.tar.gz
    tar -zxC /usr/src -f lua-nginx-module-v$NGINX_LUA_MODULE_VERSION.tar.gz
    tar -zxC /usr/src -f ngx_devel_kit-v${DEVEL_KIT_VERSION}.tar.gz
    tar -zxC /usr/src -f LuaJIT-$LUAJIT_VERSION.tar.gz
    
    rm -f nginx.tar.gz
    rm -f lua-nginx-module-v${NGINX_LUA_MODULE_VERSION}.tar.gz
    rm -f openssl-${OPENSSL_VERSION}.tar.gz
    rm -f headers-more-nginx-module-v${HEADERS_MORE_VERSION}.tar.gz
    rm -f nginx_upstream_check_module-v${UPSTREAM_CHECK_VERSION}.tar.gz
    rm -f lua-nginx-module-v$NGINX_LUA_MODULE_VERSION.tar.gz
    rm -f ngx_devel_kit-v${DEVEL_KIT_VERSION}.tar.gz
    rm -f LuaJIT-$LUAJIT_VERSION.tar.gz
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
_downloadfiles
install_lua
install_nginx
_clean


