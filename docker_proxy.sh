#!/bin/bash

mkdir /etc/systemd/system/docker.service.d

tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://192.168.1.120:8123"
EOF

systemctl daemon-reload
systemctl restart docker

systemctl show docker --property Environment
