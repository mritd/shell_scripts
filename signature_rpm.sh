#/bin/bash

rm -f /data/repo/centos/7/x86_64/{kubelet*,kubeadm*,kubernetes-cni*,kubectl*}

echo %_signature gpg > ~/.rpmmacros
echo "%_gpg_name mritd (mritd rpm repository)" >> ~/.rpmmacros

for rpmName in `ls ~/kubeadm_release/rpm/output/x86_64/*.rpm`; do
  rpm --addsign $rpmName
  cp -f $rpmName /data/repo/centos/7/x86_64
done

docker exec -it mritd_rpm_1 /root/flush.sh
