#!/bin/bash

# This script is used to create etcd | flannel | kubernetes RPM
# You can use the "./build_rpm_tool.sh etcd VERSION" to create a etcd RPM
# Kubernetes and flannel use the same command to create the RPM

targetModel=$1
version=$2

if [ -z "$targetModel" ] || [ -z "$version" ];then
  echo -e "\033[33mtargetModel or version is blank!\033[0m"
  echo -e "\033[32mUse ./build_rpm_tool.sh etcd|flannel|kubernetes VSERSION to build rpm\033[0m"
  echo -e "\033[32mexample: ./build_rpm_tool.sh etcd 3.0.7\033[0m"
  exit 1
fi

if [ ! "$targetModel" == "etcd" ] && [ ! "$targetModel" == "flannel" ] && [ ! "$targetModel" == "kubernetes" ] && [ ! "$targetModel" == "k8s" ]; then
  echo -e "\033[31mThe script only support etcd|flannel|kubernetes!\033[0m"
  echo -e "\033[32mUse build_rpm.sh etcd|flannel|kubernetes VSERSION to build rpm\033[0m"
  echo -e "\033[32mexample: ./build_rpm_tool.sh etcd 3.0.7\033[0m"
  exit 1
fi

echo -e "\033[32mbuild $targetModel rpm!\033[0m"
echo -e "\033[32mtarget version: $version\033[0m"
echo -e "\033[33mclean old files!\033[0m"
rm -rf build_tmp

echo -e "\033[32mcreate tmp dir...\033[0m"
if [ ! -d build_rpms ]; then
  mkdir build_rpms
fi
mkdir build_tmp  && cd build_tmp

# update
echo -e "\033[32msystem updating...\033[0m"
yum update -y > /dev/null 2>&1
yum upgrade -y > /dev/null 2>&1

echo -e "\033[32minstall build tools...\033[0m"
yum install wget curl git rpm-build epel-release yum-utils -y > /dev/null 2>&1

# install rvm and ruby
echo -e "\033[32minstall rvm...\033[0m"
PATH=$PATH:/usr/local/rvm/bin:/usr/local/rvm/rubies/ruby-2.3.0/bin
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 > /dev/null 2>&1
curl -sSL https://get.rvm.io | bash -s stable > /dev/null 2>&1
echo "ruby_url=https://cache.ruby-china.org/pub/ruby" >> /usr/local/rvm/user/db
rvm requirements > /dev/null 2>&1

echo -e  "\033[32minstall ruby...\033[0m"
rvm install 2.3.0 > /dev/null 2>&1
rvm use 2.3.0 --default > /dev/null 2>&1

echo -e  "\033[32minstall bundler...\033[0m"
gem install bundler > /dev/null 2>&1

echo -e  "\033[32minstall fpm...\033[0m"
gem install fpm > /dev/null 2>&1

# download target package and make package
if [ "$targetModel" == "etcd" ];then
  echo -e "\033[32mdownload etcd release package...\033[0m"
  wget https://github.com/coreos/etcd/releases/download/v$version/etcd-v$version-linux-amd64.tar.gz > /dev/null 2>&1
  tar -zxvf etcd-v$version-linux-amd64.tar.gz > /dev/null 2>&1

  echo -e "\033[32mdownload etcd old rpm...\033[0m"
  yumdownloader etcd > /dev/null 2>&1

  echo -e  "\033[32munpackage rpm...\033[0m"
  rpm2cpio *.rpm | cpio -idmv > /dev/null 2>&1
  rm -f *.rpm

  echo -e  "\033[32mreplace new files...\033[0m"
  rm -f usr/bin/*
  cp etcd-v$version-linux-amd64/{etcd,etcdctl} usr/bin

  echo -e  "\033[32mmake rpm scripts...\033[0m"
  tee preinstall.sh > /dev/null 2>&1 <<EOF
getent group etcd >/dev/null || groupadd -r etcd
getent passwd etcd >/dev/null || useradd -r -g etcd -d /var/lib/etcd \\
        -s /sbin/nologin -c "etcd user" etcd
EOF

  tee postinstall.sh > /dev/null 2>&1 <<EOF
if [ \$1 -eq 1 ] ; then
        # Initial installation
        systemctl preset etcd.service >/dev/null 2>&1 || :
fi
EOF

  tee preuninstall.sh > /dev/null 2>&1 <<EOF
if [ \$1 -eq 0 ] ; then
        # Package removal, not upgrade
        systemctl --no-reload disable etcd.service > /dev/null 2>&1 || :
        systemctl stop etcd.service > /dev/null 2>&1 || :
fi
EOF

  tee postuninstall.sh > /dev/null 2>&1 <<EOF
systemctl daemon-reload >/dev/null 2>&1 || :
EOF

  echo -e  "\033[32mmake new rpm...\033[0m"
  fpm -s dir -t rpm -n "etcd" -v $version --pre-install preinstall.sh --post-install postinstall.sh --pre-uninstall preuninstall.sh --post-uninstall postuninstall.sh etc usr var > /dev/null 2>&1



elif [ "$targetModel" == "flannel" ];then

  echo -e "\033[32mdownload flannel release package...\033[0m"
  wget https://github.com/coreos/flannel/releases/download/v$version/flannel-v$version-linux-amd64.tar.gz > /dev/null 2>&1
  tar -zxvf flannel-v$version-linux-amd64.tar.gz > /dev/null 2>&1

  echo -e "\033[32mdownload flannel old rpm...\033[0m"
  yumdownloader flannel > /dev/null 2>&1

  echo -e  "\033[32munpackage rpm...\033[0m"
  rpm2cpio *.rpm | cpio -idmv > /dev/null 2>&1
  rm -f *.rpm

  echo -e  "\033[32mreplace new files...\033[0m"
  rm -f usr/bin/flanneld
  cp flanneld usr/bin/flanneld

  rm -f usr/libexec/flannel/mk-docker-opts.sh
  cp mk-docker-opts.sh usr/libexec/flannel/mk-docker-opts.sh

  echo -e  "\033[32mmake rpm scripts...\033[0m"
  tee postinstall.sh > /dev/null 2>&1 <<EOF
if [ \$1 -eq 1 ] ; then
        # Initial installation
        systemctl preset flanneld.service >/dev/null 2>&1 || :
fi
EOF

  tee preuninstall.sh > /dev/null 2>&1 <<EOF
# clean tempdir and workdir on removal or upgrade
if [ \$1 -eq 0 ] ; then
        # Package removal, not upgrade
        systemctl --no-reload disable flanneld.service > /dev/null 2>&1 || :
        systemctl stop flanneld.service > /dev/null 2>&1 || :
fi
EOF

  tee postuninstall.sh > /dev/null 2>&1 <<EOF
systemctl daemon-reload >/dev/null 2>&1 || :
if [ \$1 -ge 1 ] ; then
        # Package upgrade, not uninstall
        systemctl try-restart flanneld.service >/dev/null 2>&1 || :
fi
EOF

  echo -e  "\033[32mmake new rpm...\033[0m"
  fpm -s dir -t rpm -n "flannel" -v $version --post-install postinstall.sh --pre-uninstall preuninstall.sh --post-uninstall postuninstall.sh etc run usr > /dev/null 2>&1



elif [ "$targetModel" == "k8s" ] || [ "$targetModel" == "kubernetes" ]; then
  echo -e "\033[32mdownload k8s release package...\033[0m"
  for binName in kubectl kube-dns hyperkube kubemark kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet;do
    wget https://storage.googleapis.com/kubernetes-release/release/v$version/bin/linux/amd64/$binName -O $binName > /dev/null 2>&1
    chmod +x $binName
    echo -e "\033[32m$binName download success...\033[0m"
  done

  echo -e "\033[32mdownload old kubernetes...\033[0m"
  wget http://upyun.mritd.me/rpms/kubernetes-1.3.6-gitae4550c.el7.centos.x86_64.rpm > /dev/null 2>&1

  echo -e  "\033[32munpackage rpm...\033[0m"
  rpm2cpio *.rpm | cpio -idmv > /dev/null 2>&1
  rm -f *.rpm

  echo -e  "\033[32mreplace new files...\033[0m"
  rm -f usr/bin/*
  cp kubectl kube-dns hyperkube kubemark kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet usr/bin/

  echo -e  "\033[32mmake rpm scripts...\033[0m"
  tee preinstall.sh > /dev/null 2>&1 <<EOF
getent group kube >/dev/null || groupadd -r kube
getent passwd kube >/dev/null || useradd -r -g kube -d / -s /sbin/nologin \\
        -c "Kubernetes user" kube
EOF

  tee postinstall.sh > /dev/null 2>&1 <<EOF
if [ \$1 -eq 1 ] ; then
        # Initial installation
        systemctl preset kube-apiserver kube-scheduler kube-controller-manager kubelet kube-proxy >/dev/null 2>&1 || :
fi
EOF

  tee preuninstall.sh > /dev/null 2>&1 <<EOF
if [ \$1 -eq 0 ] ; then
        # Package removal, not upgrade
        systemctl --no-reload disable kube-apiserver kube-scheduler kube-controller-manager kubelet kube-proxy > /dev/null 2>&1 || :
        systemctl stop kube-apiserver kube-scheduler kube-controller-manager kubelet kube-proxy > /dev/null 2>&1 || :
fi
EOF

  tee postuninstall.sh > /dev/null 2>&1 <<EOF
systemctl daemon-reload >/dev/null 2>&1 || :
EOF

  echo -e  "\033[32mmake new rpm...\033[0m"
  fpm -s dir -t rpm -n "kubernetes" -v $version --pre-install preinstall.sh --post-install postinstall.sh --pre-uninstall preuninstall.sh --post-uninstall postuninstall.sh etc usr var > /dev/null 2>&1

fi


echo -e  "\033[32mmove rpms and remove tmp dir...\033[0m"
mv *.rpm ../build_rpms && cd ../ && rm -rf build_tmp

echo -e "\033[32mbuild seccess!\033[0m"


# 谦(zhuang)虚(bi)
#                               88                 88
#                               ""   ,d            88
#                                    88            88
# 88,dPYba,,adPYba,  8b,dPPYba, 88 MM88MMM ,adPPYb,88
# 88P'   "88"    "8a 88P'   "Y8 88   88   a8"    `Y88
# 88      88      88 88         88   88   8b       88
# 88      88      88 88         88   88,  "8a,   ,d88
# 88      88      88 88         88   "Y888 `"8bbdP"Y8

echo -e ""
echo -e "\033[32m                              88                 88\033[0m"
echo -e "\033[32m                              \"\"   ,d            88  \033[0m"
echo -e "\033[32m                                   88            88\033[0m"
echo -e "\033[32m88,dPYba,,adPYba,  8b,dPPYba, 88 MM88MMM ,adPPYb,88\033[0m"
echo -e "\033[32m88P'   \"88\"    \"8a 88P'   \"Y8 88   88   a8\"    \`Y88\033[0m"
echo -e "\033[32m88      88      88 88         88   88   8b       88 \033[0m"
echo -e "\033[32m88      88      88 88         88   88,  \"8a,   ,d88\033[0m"
echo -e "\033[32m88      88      88 88         88   \"Y888 \`\"8bbdP\"Y8\033[0m"
echo -e ""
echo -e ""
