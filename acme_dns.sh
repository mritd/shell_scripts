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

echo -e "\033[32mSystem updateing.......\033[0m"
yum update -y 

echo -e "\033[32mInstall nc and crontabs......\033[0m"
yum install -y nc crontabs

if ! $? ;then
  echo -e "\033[31mInstall nc or crontabs failed, System exiting!\033[0m"
  exit 1
fi

echo -e "\033[32mInstall acme.sh.......\033[0m"
curl https://get.acme.sh | bash

echo -e "\033[32mCreate SSL CRT.......\033[0m"
~/.acme.sh/acme.sh   --issue   --dns dns_GD -d mritd.me -d www.mritd.me -d cdn.mritd.me

echo -e "\033[32mCopy SSL CRT......\033[0m"
~/.acme.sh/acme.sh  --installcert -d mritd.me -d www.mritd.me \
                    --keypath /etc/nginx/ssl/mritd.me.key \
                    --certpath /etc/nginx/ssl/mritd.me.cer \
                    --reloadcmd "cd /root/docker/mritd && docker-compose restart" 

echo -e "\033[32mUpdate acme.sh......\033[0m"
~/.acme.sh/acme.sh  --upgrade  --auto-upgrade

