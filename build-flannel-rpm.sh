#!/bin/bash

flannel_version=$1
echo -e  "\033[32mflannel version: $flannel_version\033[0m"

if [ -z "$flannel_version" ] ;then
  echo -e "\033[33mflannel_version is blank!\033[0m"
  echo -e "\033[32mUse build-flannel-rpm.sh VSERSION to build rpm\033[0m"
  exit 1
fi

echo -e "\033[33mclean old files!\033[0m"
rm -rf flannel* 2>&1 >> /dev/null

echo -e "\033[32mcreate tmp dir...\033[0m"
mkdir flannel && cd flannel

# update

echo -e  "\033[32msystem updating...\033[0m"

yum update -y 2>&1 >> /dev/null
yum upgrade -y 2>&1 >> /dev/null
yum install epel-release -y 2>&1 >> /dev/null

# install ruby

echo -e  "\033[32minstall rvm...\033[0m"

PATH=$PATH:/usr/local/rvm/bin/:/usr/local/rvm/rubies/ruby-2.3.0/bin/
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 2>&1 >> /dev/null
curl -sSL https://get.rvm.io | bash -s stable 2>&1 >> /dev/null
mkdir -p ~/.rvm/user/ 
echo "ruby_url=https://cache.ruby-china.org/pub/ruby" > ~/.rvm/user/db
rvm requirements 2>&1 >> /dev/null

echo -e  "\033[32minstall ruby...\033[0m"
rvm install 2.3.0 2>&1 >> /dev/null
rvm use 2.3.0 --default 2>&1 >> /dev/null

echo -e  "\033[32minstall bundler...\033[0m"
gem install bundler 2>&1 >> /dev/null

echo -e  "\033[32minstall fpm...\033[0m"
gem install fpm 2>&1 >> /dev/null

# download flanneld

echo -e  "\033[32mdownload flanneld...\033[0m"

wget "https://github.com/coreos/flannel/releases/download/v$flannel_version/flannel-v$flannel_version-linux-amd64.tar.gz"
tar -zxvf flannel-v$flannel_version-linux-amd64.tar.gz

# download old flannel rpm

echo -e  "\033[32mdownload old flannel rpm...\033[0m"
yum -y install yum-utils 2>&1 >> /dev/null
yumdownloader flannel

echo -e  "\033[32munpackage rpm...\033[0m"
rpm2cpio *.rpm | cpio -idmv

# replace old flannel

echo -e  "\033[32mcpoy new files...\033[0m"
rm -f usr/bin/flanneld
cp flanneld usr/bin/flanneld

rm -f usr/libexec/flannel/mk-docker-opts.sh
cp mk-docker-opts.sh usr/libexec/flannel/mk-docker-opts.sh

# make script

echo -e  "\033[32mmake rpm scripts...\033[0m"

tee postinstall.sh 2>&1 >> /dev/null <<EOF
if [ $1 -eq 1 ] ; then
        # Initial installation
        systemctl preset flanneld.service >/dev/null 2>&1 || :
fi
EOF

tee postuninstall.sh 2>&1 >> /dev/null <<EOF
systemctl daemon-reload >/dev/null 2>&1 || :
if [ $1 -ge 1 ] ; then
        # Package upgrade, not uninstall
        systemctl try-restart flanneld.service >/dev/null 2>&1 || :
fi
EOF

tee preuninstall.sh 2>&1 >> /dev/null <<EOF
if [ $1 -eq 0 ] ; then
        # Package removal, not upgrade
        systemctl --no-reload disable flanneld.service > /dev/null 2>&1 || :
        systemctl stop flanneld.service > /dev/null 2>&1 || :
fi
EOF

# make packge

echo -e  "\033[32mmake new flannel rpm...\033[0m"

fpm -s dir -t rpm -n "flannel" -v $flannel_version --post-install postinstall.sh --pre-uninstall preuninstall.sh --post-uninstall postuninstall.sh etc run usr

echo -e  "\033[32mmove rpms...\033[0m"
mv *.rpm ../

echo -e  "\033[32mremove tmp dir...\033[0m"
cd ../ && rm -rf flannel
