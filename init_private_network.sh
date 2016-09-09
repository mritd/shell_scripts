#!/bin/bash

# This script is use to automatically configure Conoha LAN IP
# reference https://www.conoha.jp/conoben/archives/10174

IPADDR=$1

if [ "$IPADDR" == "" ]; then
  echo -e "\033[33merror: ip address is blank\033[0m"
  echo -e "\033[32muse ./init_private_neiwork.sh IPADDRESS NETMASK [ETH_BUMBER] [MAC_ADDRESS]\033[0m"
  exit 1
fi

NETMASK=$2

if [ ""$NETMASK"" == "" ]; then
  echo -e "\033[33merror: netmask is blank\033[0m"
  echo -e "\033[32muse ./init_private_neiwork.sh IPADDRESS NETMASK [ETH_BUMBER] [MAC_ADDRESS]\033[0m"
  exit 1
fi

ETH_BUMBER=$3

if [ "$ETH_BUMBER" == "" ]; then
  ETH_BUMBER = "eth1"
fi

MAC_ADDRESS=$4

if [ "$MAC_ADDRESS" == "" ]; then
  yum update -y && yum upgrade -y && yum install net-tools
  MAC_ADDRESS = `ifconfig "$ETH_BUMBER" | grep ether | awk -F" " '{print $2}'`
  if [ "$MAC_ADDRESS" == "" ]; then
    echo -e "\033[33mget MAC_ADDRESS"
    echo -e "\033[33mget MAC_ADDRESS failed! please input MAC_ADDRESS!"
    exit 1
  fi
fi
https://www.conoha.jp/conoben/archives/10174
# setting network
tee /etc/sysconfig/network-scripts/ifcfg-"$ETH_BUMBER" >> /dev/null 2>&1 <<EOF
DEVICE="$ETH_BUMBER"
TYPE=Ethernet
HWADDR="$MAC_ADDRESS"
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
IPADDR="$IPADDR"
NETMASK="$NETMASK"
EOF

tee /etc/iproute2/rt_tables >> /dev/null 2>&1 <<EOF
201     gate1       "$IPADDR"
EOF

tee /etc/sysconfig/network-scripts/rule-"$ETH_BUMBER" >> /dev/null 2>&1 <<EOF
from "$IPADDR" table gate1
EOF

tee /etc/sysconfig/network-scripts/route-"$ETH_BUMBER" >> /dev/null 2>&1 <<EOF
default via "$IPADDR" table gate1
EOF

systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl restart network
