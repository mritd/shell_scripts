#!/bin/bash

GD_Key=$1
GD_Secret=$2

if [ "$GD_Key" == "" ];then
  echo -e "\033[31merror: GD_Key is blank!\033[0m"
  exit 1
fi

if [ "$GD_Secret" == "" ];then
  echo -e "\033[31merror: GD_Secret is blank!\033[0m"
  exit 1
fi

yum update -y 

yum install -y nc crontabs

curl  https://get.acme.sh | bash

~/.acme.sh/acme.sh   --issue   --dns dns_GD -d mritd.me -d www.mritd.me -d cdn.mritd.me

~/.acme.sh/acme.sh  --installcert -d mritd.me -d www.mritd.me \
                    --keypath /etc/nginx/ssl/mritd.me.key \
                    --certpath /etc/nginx/ssl/mritd.me.cer \
                    --reloadcmd "cd /root/docker/mritd && docker-compose restart" 

~/.acme.sh/acme.sh  --upgrade  --auto-upgrade

