#!/bin/bash

# import key
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

# install elrepo repo
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

# install kernel
yum --enablerepo=elrepo-kernel install  kernel-ml-devel kernel-ml -y

# modify grub
grub2-set-default 0
