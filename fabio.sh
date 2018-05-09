#!/bin/bash

set -e

FABIO_VERSION="1.5.8"
FABIO_DONWLOAD_URL="https://github.com/fabiolb/fabio/releases/download/v${FABIO_VERSION}/fabio-${FABIO_VERSION}-go1.10-linux_amd64"

preinstall(){
    getent group fabio >/dev/null || groupadd -r fabio
    getent passwd fabio >/dev/null || useradd -r -g fabio -d /var/lib/fabio -s /sbin/nologin -c "fabio user" fabio
    if [ ! -d /etc/fabio ]; then
        mkdir /etc/fabio
    fi
}

postinstall(){
    # Initial installation
    systemctl --no-reload preset fabio.service >/dev/null 2>&1 || :
    systemctl enable fabio
}

preuninstall(){
    # Package removal, not upgrade
    systemctl --no-reload disable --now fabio.service > /dev/null 2>&1 || :
}

install(){
    wget ${FABIO_DONWLOAD_URL} -O /usr/local/bin/fabio
    chmod +x /usr/local/bin/fabio
    wget https://raw.githubusercontent.com/fabiolb/fabio/master/fabio.properties -O /etc/fabio/fabio.properties
	cat >/lib/systemd/system/fabio.service <<EOF
[Unit]
Description=Fabio Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=fabio
# set GOMAXPROCS to number of processors
ExecStart=/bin/bash -c "GOMAXPROCS=$(nproc) /usr/local/bin/fabio -cfg /etc/fabio/fabio.properties"
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
}

uninstall(){
    systemctl stop fabio || true
    rm -rf /usr/local/bin/fabio \
        /etc/fabio \
        /lib/systemd/system/fabio.service
    systemctl daemon-reload
    userdel fabio
}

if [ "$1" == "install" ]; then
    preinstall
    install
    postinstall
elif [ "$1" == "uninstall" ]; then
    preuninstall
    uninstall
else
    echo -e "\033[31mError: command not support!\033[0m"
    exit 1
fi
