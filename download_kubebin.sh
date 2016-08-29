#/bin/bash

kubeVersion=v1.3.5

mkdir kubebin 
for binName in kubectl kube-dns hyperkube kubemark kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet;do
  wget https://storage.googleapis.com/kubernetes-release/release/$kubeVersion/bin/linux/amd64/$binName -O kubebin/$binName
  chmod +x kubebin/$binName
done
