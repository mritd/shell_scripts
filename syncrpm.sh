#!/bin/bash

# clean old files
upx rm centos/7/x86_64/\*
upx rm centos/7/x86_64/repodata/\*

# waiting cdn clean cache
sleep 120

# sync rpm
cd /data && upx sync repo

