#!/bin/bash

# clean old files
upx rm centos/7/x86_64/\*
upx rm centos/7/x86_64/repodata/\*

# waiting cdn clean cache
sleep 120

# sync rpm
cd /data/repo/centos/7/x86_64/ && for rpmName in `ls *.rpm`;do upx put $rpmName centos/7/x86_64/;done
cd /data/repo/centos/7/x86_64/repodata/ && for repodata in `ls`;do upx put $repodata centos/7/x86_64/repodata/;done

