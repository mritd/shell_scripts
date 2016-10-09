#!/bin/bash

containers=(kube-proxy-amd64:v1.4.0 kube-discovery-amd64:1.0 kubedns-amd64:1.7 kube-scheduler-amd64:v1.4.0 kube-controller-manager-amd64:v1.4.0 kube-apiserver-amd64:v1.4.0 etcd-amd64:2.2.5 kube-dnsmasq-amd64:1.3 exechealthz-amd64:1.1 pause-amd64:3.0)

echo -e "\033[33mclean old files!\033[0m"
rm -rf ~/kube_images > /dev/null 2>&1
rm -f ~/kube_images.tar.gz > /dev/null 2>&1

echo -e "\033[32mcreate download directory...\033[0m"
mkdir ~/kube_images

for containerName in ${containers[@]} ; do
  echo -e "\033[32mpull image: $containerName...\033[0m"
  docker pull gcr.io/google_containers/$containerName
  if [ ! "$?"=="0" ]; then
    echo -e "\033[31merror: pull image: $containerName failed!\033[0m"
    exit 1
  fi
  echo -e "\033[32msave image: $containerName...\033[0m"
  docker save gcr.io/google_containers/$containerName > ~/kube_images/$containerName.tar

  if [ -f ~/kube_images/$containerName.tar ]; then
    echo -e "\033[32mdownload $containerName image success!\033[0m"
  else
    echo -e "\033[31mdownload $containerName image failed!\033[0m"
    exit 1
  fi
done

echo -e "\033[32mcreate images package...\033[0m"
(cd ~/kube_images && tar -zcvf ~/kube_images.tar.gz *.tar)

if [ -f ~/kube_images.tar.gz ]; then
  echo -e "\033[32mcreate images package success!\033[0m"
  echo -e "\033[32mclean temp files...\033[0m"
  rm -rf ~/kube_images
else
  echo -e "\033[31merror: create images package failed!\033[0m"
  exit 1
fi
