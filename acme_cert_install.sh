#!/bin/bash

/usr/bin/read -p "请输入 keypath 目录:" keypath
/usr/bin/read -p "请输入 certpath 目录:" certpath
/usr/bin/read -p "请输入域名(多个以空格分割):" domains
/usr/bin/read -p "请输入重载命令(非必选):" reloadcmd

if [ "$keypath" == "" ] ||  [ "$certpath" == "" ] ||  [ "$domains" == "" ]; then
  echo -e "\033[31merror: keypath、certpath or domains is blank!"
  exit 1
fi

allDomian=($domains)

for domainName in ${allDomian[@]}; do
  installcert+=" -d $domainName"
done

~/.acme.sh/acme.sh  --installcert $installcert \
                    --keypath $keypath${allDomian[0]}.key \
                    --certpath $certpath${allDomian[0]}.cer \
                    --reloadcmd "$reloadcmd"
