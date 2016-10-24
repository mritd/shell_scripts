#!/bin/bash

# This script is used to automatically install the Kubernetes 1.4 cluster using the kubeadm command

nodeName=$1

if [ "$nodeName" != "master" ] && [ "$nodeName" != "node" ]; then
  echo -e "\033[31mError: Enter master or node to create a Kubernetes cluster!\0mm[0m"
  echo -e "\033[33mExample: ./$0 master | node\033[0m"
  exit 1
fi

# Clean up related files
echo -e "\033[32mStop kubelet...\033[0m"
systemctl stop kubelet

/usr/bin/read -p "Do you want to clean up the Docker Container?(y/n): " cleanContainer

if [ "$cleanContainer"=="y" ]; then
  echo -e "\033[33mStart Deleting all Docker Containers...\033[0m"
  docker rm -f -v $(docker ps -q)
  echo -e "\033[32mClean up the Docker Container successfully...\033[0m"
fi

echo -e "\033[32mClean up Kubernetes residual files...\033[0m"

if [ -d /var/lib/kubelet ]; then
  find /var/lib/kubelet | xargs -n 1 findmnt -n -t tmpfs -o TARGET -T | uniq | xargs -r umount -v
fi
rm -r -f /etc/kubernetes /var/lib/kubelet /var/lib/etcd

# Install the Kubernetes rpm package
rm -rf rpms && mkdir rpms
yum install -y socat

rpms=(kubectl-1.4.3-1.x86_64.rpm \
      kubeadm-1.5.0-1.alpha.1.409.714f816a349e79.x86_64.rpm \
      kubelet-1.4.3-1.x86_64.rpm \
      kubernetes-cni-0.3.0.1-1.07a8a2.x86_64.rpm )

for rpmName in ${rpms[@]}; do
  wget http://upyun.mritd.me/kubernetes/$rpmName -O rpms/$rpmName
done

rpm -ivh rpms/*.rpm

# Clean up related files(Kubelet installation will produce some useless configuration file)
rm -r -f /etc/kubernetes /var/lib/kubelet /var/lib/etcd >/dev/null 1>&2

systemctl enable docker
systemctl enable kubelet
systemctl start docker
systemctl start kubelet

# Desable SELinux
setenforce 0

# Download adn Load the Kubernetes image
images=(kube-proxy-amd64:v1.4.1 \
        kube-discovery-amd64:1.0 \
        kubedns-amd64:1.7 \
        kube-scheduler-amd64:v1.4.1 \
        kube-controller-manager-amd64:v1.4.1 \
        kube-apiserver-amd64:v1.4.1 \
        etcd-amd64:2.2.5 \
        kube-dnsmasq-amd64:1.3 \
        exechealthz-amd64:1.1 \
        pause-amd64:3.0 \
        kubernetes-dashboard-amd64:v1.4.1 )
for imageName in ${images[@]} ; do
  docker pull mritd/$imageName
  docker tag mritd/$imageName gcr.io/google_containers/$imageName
  docker rmi mritd/$imageName
done

# Processes the host name
/usr/bin/read -p "Please enter a hostname(Example: 192-168-1-100.node): " hostName

if [ "$hostName"!="" ]; then
  echo "$hostName" > /etc/hostname
  echo "127.0.0.1    $hostName" >> /etc/hosts
else
  echo -e "\033[31mError: hostname is blank!\033[0m"
  exit 1
fi

if [ "$nodeName"=="master" ]; then

  /usr/bin/read -p "Please enter the IP to bind(The Kubernetes API listens for this address): " bindIP

  if [ "bindIP"!="" ]; then
    kubeadm init --api-advertise-addresses=$bindIP
  else
    kubeadm init
  fi
elif [ "$nodeName"=="node" ]; then

  /usr/bin/read -p "Enter the connection master token: " kubeMasterToken
  /usr/bin/read -p "Please enter the master IP address: " kubeMasterIP

  if [ "$kubeMasterToken"!="" ] || [ "$kubeMasterIP"!="" ]; then
    kubeadm join --token $kubeMasterToken $kubeMasterIP
  else
    echo -e "\033[0mError: kubeMasterToken or kubeMasterIP is blank!\033[0m"
    exit
  fi
fi
