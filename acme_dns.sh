#!/bin/bash

export GD_Key=$1
export GD_Secret=$2

for i in `seq 3 $#`;do
  Domains+=" -d $3"
  echo -e "\033[32mDomains: $3\033[0m"
  shift
done

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

if [ ! "$?" == "0" ];then
  echo -e "\033[31mInstall nc or crontabs failed, System exiting!\033[0m"
  exit 1
fi

echo -e "\033[32mInstall acme.sh.......\033[0m"
curl https://get.acme.sh | bash

echo -e "\033[32mCreate SSL CRT.......\033[0m"
~/.acme.sh/acme.sh --issue --dns dns_gd $Domains

echo -e "\033[32mUpdate acme.sh......\033[0m"
~/.acme.sh/acme.sh  --upgrade  --auto-upgrade
