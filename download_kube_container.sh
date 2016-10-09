#!/bin/bash

containers=(kube-proxy-amd64:v1.4.0 kube-discovery-amd64:1.0 kubedns-amd64:1.7 kube-scheduler-amd64:v1.4.0 kube-controller-manager-amd64:v1.4.0 kube-apiserver-amd64:v1.4.0 etcd-amd64:2.2.5 kube-dnsmasq-amd64:1.3 exechealthz-amd64:1.1 pause-amd64:3.0)

for containerName in ${containers[@]} ; do
  echo -e "\033[32mpull image: $containerName...\033[0m"
  docker pull gcr.io/google_containers/$containerName
  if $?; then
    echo -e "\033[31merror: pull image: $containerName failed!"
    exit 1
  fi
  echo -e "\033[32msave image: $containerName..."
  docker save gcr.io/google_containers/$containerName > $containerName.tar
done
