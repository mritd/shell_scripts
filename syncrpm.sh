#!/bin/bash

set -e

# clean old files
upx rm centos/7/x86_64/\*
upx rm centos/7/x86_64/repodata/\*

# waiting cdn clean cache
echo "Wating cdn sync:"
for i in `seq -w 120 -1 1`;do
    echo -ne "\033[1;31;32m\b\b\b$i\033[0m";
    sleep 1;
done

# sync rpm
cd /data/repo/centos/7/x86_64/ && for rpmName in `ls *.rpm`;do upx put $rpmName centos/7/x86_64/;done
cd /data/repo/centos/7/x86_64/repodata/ && for repodata in `ls`;do upx put $repodata centos/7/x86_64/repodata/;done

