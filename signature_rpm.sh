#/bin/bash

set -e

RPM_DIR=$1

if [ "$RPM_DIR" == "" ];then
    echo -e "\033[31mError: RPM_DIR is blank!\033[0m"
    exit 1
fi
#yum install rpm-sign -y 

# clean old files
rm -f /data/repo/centos/7/x86_64/kubernetes-*

# signature rpms
echo %_signature gpg > ~/.rpmmacros
echo "%_gpg_name mritd (mritd rpm repository)" >> ~/.rpmmacros

for rpmName in `ls ${RPM_DIR}/*.rpm`; do
  rpm --addsign $rpmName
  cp -f $rpmName /data/repo/centos/7/x86_64
done

# create repodata
`pwd`/flush_repo.sh

# sync cdn
`pwd`/syncrpm.sh
