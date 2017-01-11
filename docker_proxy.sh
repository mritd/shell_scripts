#!/bin/bash

mkdir /etc/systemd/system/docker.service.d

tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="ALL_PROXY=socks5://192.168.1.120:1083"
EOF

systemctl daemon-reload
systemctl restart docker

systemctl show docker --property Environment
