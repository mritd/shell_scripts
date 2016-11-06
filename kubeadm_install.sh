#!/bin/bash

# This script is used to automatically install the Kubernetes 1.4 cluster using the kubeadm command

NODENAME=$1
KUBEVERSION=$2

if [ "$NODENAME" != "master" ] && [ "$NODENAME" != "node" ]; then
  echo -e "\033[31mError: Enter master or node to create a Kubernetes cluster!\033[0m"
  echo -e "\033[33mExample: ./$0 master | node v1.4.1\033[0m"
  exit 1
fi

if [ "$KUBEVERSION" == "" ]; then
  echo -e "\033[31mError: Please enter the version of kubernetes image to use!\033[0m]"
  echo -e "\033[33mExample: ./$0 master | node v1.4.1\033[0m"
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
tee /etc/yum.repos.d/mritd.repo <<EOF
[mritdrepo]
name=Mritd Repository
baseurl=https://rpm.mritd.me/centos/7/x86_64
enabled=1
gpgcheck=1
gpgkey=https://cdn.mritd.me/keys/rpm.public.key
EOF

yum install -y kubelet kubectl kubernetes-cni kubeadm ebtables

# Clean up related files(Kubelet installation will produce some useless configuration file)
rm -r -f /etc/kubernetes /var/lib/kubelet /var/lib/etcd >/dev/null 1>&2

systemctl enable docker
systemctl enable kubelet
systemctl start docker
systemctl start kubelet

# Desable SELinux
setenforce 0

# Download adn Load the Kubernetes image
images=(kube-proxy-amd64:$KUBEVERSION \
        kube-discovery-amd64:1.0 \
        kubedns-amd64:1.7 \
        kube-scheduler-amd64:$KUBEVERSION \
        kube-controller-manager-amd64:$KUBEVERSION \
        kube-apiserver-amd64:$KUBEVERSION \
        etcd-amd64:2.2.5 \
        kube-dnsmasq-amd64:1.3 \
        exechealthz-amd64:1.1 \
        pause-amd64:3.0 \
        kubernetes-dashboard-amd64:v1.4.1)
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

if [ "$NODENAME"=="master" ]; then

  /usr/bin/read -p "Please enter the IP to bind(The Kubernetes API listens for this address): " bindIP

  if [ "bindIP"!="" ]; then
    kubeadm init --api-advertise-addresses=$bindIP
  else
    kubeadm init
  fi
elif [ "$NODENAME"=="node" ]; then

  /usr/bin/read -p "Enter the connection master token: " kubeMasterToken
  /usr/bin/read -p "Please enter the master IP address: " kubeMasterIP

  if [ "$kubeMasterToken"!="" ] || [ "$kubeMasterIP"!="" ]; then
    kubeadm join --token $kubeMasterToken $kubeMasterIP
  else
    echo -e "\033[0mError: kubeMasterToken or kubeMasterIP is blank!\033[0m"
    exit
  fi
fi
