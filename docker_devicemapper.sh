#!/bin/bash

device_name=$1
force_delete=$2

if [ "$1" == "" ]; then
  echo -e ""
  echo -e "\033[33muse \"./docker_devicemapper.sh DEVVICE [-f]\" config docker devicemapper!\033[0m"
  echo -e "\033[33mIf using the -f option will be forced to delete existing devicemapper!\033[0m"
  echo -e "\033[32mexample: /docker_devicemapper.sh /dev/sdb -f\033[0m"
  exit 1
fi

yum install -y lvm2

if [ "$force_delete" != "" ] && [ "$force_delete" == "-f" ]; then
  echo -e "\033[33mForced to delete old devicemapper!\033[0m"
  lvremove docker -ff
fi

if mount | grep $device_name 2>&1 > /dev/null ; then
  if ! umount $device_name ; then
    echo -e "\033[31mThe device is busy, umount failure!\033[0m"
    exit 1
  fi
fi

echo -e "\033[32mCreate a physical volume replacing $device_name with your block device.\033[0m"
if [ "$force_delete" == "-f" ]; then
  if ! pvcreate $device_name -ff ; then
    echo -e "\033[31mError: Create a physical volume failed!\033[0m"
    exit 1
  fi
else
  if ! pvcreate $device_name ; then
    echo -e "\033[31mError: Create a physical volume failed!\033[0m"
    echo -e "\033[33mIf you want to continue, please use the -f option!\033[0m"
    exit 1
  fi
fi

echo -e "\033[32mCreate a ‘docker’ volume group.\033[0m"
vgcreate docker $device_name

echo -e "\033[32mCreate a thin pool named thinpool.\033[0m"
lvcreate --wipesignatures y -n thinpool docker -l 95%VG
lvcreate --wipesignatures y -n thinpoolmeta docker -l 1%VG

echo -e "\033[32mConvert the pool to a thin pool.\033[0m"
lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta

echo -e "\033[32mConfigure autoextension of thin pools via an lvm profile.\033[0m"
tee /etc/lvm/profile/docker-thinpool.profile << EOF
activation {
    thin_pool_autoextend_threshold=80
    thin_pool_autoextend_percent=20
}
EOF

echo -e "\033[32mApply your new lvm profile\033[0m"
lvchange --metadataprofile docker-thinpool docker/thinpool

echo -e "\033[33mVerify the lv is monitored.\033[0m"
lvs -o+seg_monitor

echo -e "\033[32mStop docker daemon.\033[0m"
systemctl stop docker

echo -e "\033[32mClear graph driver directory.\033[0m"
rm -rf /var/lib/docker/*

echo -e "\033[32mConfigure the Docker daemon with specific devicemapper options.\033[0m"
if ! grep "\-\-storage-driver=devicemapper" /usr/lib/systemd/system/docker.service 2>&1 > /dev/null ;then
  sed -i "s@ExecStart=/usr/bin/dockerd@ExecStart=/usr/bin/dockerd --storage-driver=devicemapper --storage-opt=dm.thinpooldev=/dev/mapper/docker-thinpool --storage-opt dm.use_deferred_removal=true --storage-opt=dm.use_deferred_deletion=true @g" /usr/lib/systemd/system/docker.service
  systemctl daemon-reload
else
  echo -e "\033[33mFound '--storage-driver=devicemapper' option,not to replace!"
fi

echo -e "\033[32mStart docker daemon.\033[0m"
systemctl start docker
