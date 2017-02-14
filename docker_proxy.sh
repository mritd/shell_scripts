#!/bin/bash

set -e

OS_TYPE=$1

if [ "$OS_TYPE" == "" ];then
    echo -e "\033[31mError: OS_TYPE is blank!\033[0m"
    echo -e "\033[32mUse: sudo $0 centos|ubuntu\033[0m"
    exit 1
elif [ "$OS_TYPE" == "centos" ];then
    mkdir /etc/systemd/system/docker.service.d || true
    tee /etc/systemd/system/docker.service.d/socks5-proxy.conf <<-EOF
    [Service]
    Environment="ALL_PROXY=socks5://192.168.1.120:1083"
EOF
elif [ "$OS_TYPE" == "ubuntu" ];then
    mkdir /lib/systemd/system/docker.service.d || true
    tee /lib/systemd/system/docker.service.d/socks5-proxy.conf <<-EOF
    [Service]
    Environment="ALL_PROXY=socks5://192.168.1.120:1083"
EOF
fi

systemctl daemon-reload
systemctl restart docker
systemctl show docker --property Environment
