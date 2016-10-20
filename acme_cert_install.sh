#!/bin/bash

shellName=`ps | grep $$ | awk '{print $4}'`

if [ "$shellName" == "zsh" ]; then
  read "keypath?请输入 keypath 目录: "
  read "certpath?请输入 certpath 目录: "
  read "domains?请输入域名(多个以空格分割): "
  read "reloadcmd?请输入重载命令(非必选): "
else
  read -p "请输入 keypath 目录: " keypath
  read -p "请输入 certpath 目录: " certpath
  read -p "请输入域名(多个以空格分割): " domains
  read -p "请输入重载命令(非必选): " reloadcmd
fi

if [ "$keypath" == "" ] ||  [ "$certpath" == "" ] ||  [ "$domains" == "" ]; then
  echo -e "\033[31merror: keypath、certpath or domains is blank!"
  exit 1
else
  mkdir -p $keypath
  mkdir -p $certpath
fi

allDomian=($domains)

for domainName in ${allDomian[@]}; do
  installcert+=" -d $domainName"
done

~/.acme.sh/acme.sh  --installcert $installcert \
                    --keypath $keypath/${allDomian[0]}.key \
                    --certpath $certpath/${allDomian[0]}.cer \
                    --reloadcmd "$reloadcmd"
