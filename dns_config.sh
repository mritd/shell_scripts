#!/bin/bash

SERVER_IP=$1

if [ "${SERVER_IP}" == "" ]; then
    echo -e "\033[31mError: SERVER_IP is blank!\033[0m"
    exit 1
fi

sed -i 's@#resolv-file.*@resolv-file=/etc/resolv.dnsmasq.conf@gi' /etc/dnsmasq.conf
sed -i 's@#no-hosts@no-hosts@gi' /etc/dnsmasq.conf
sed -i "s@#listen-address.*@listen-address=127.0.0.1,$1@gi" /etc/dnsmasq.conf
sed -i 's@#addn-hosts.*@addn-hosts=/etc/dnsmasq.hosts@gi' /etc/dnsmasq.conf

touch /etc/dnsmasq.hosts
echo 'nameserver 114.114.114.114' >> /etc/resolv.dnsmasq.conf
