#!/bin/bash

rm -rf /backup >& /dev/null &&  mkdir /backup

cd / && tar -zcvf root.tar.gz root && mv root.tar.gz /backup
cd / && tar -zcvf data.tar.gz data && mv data.tar.gz /backup
cd /etc && tar -zcvf nginx.tar.gz nginx && mv nginx.tar.gz /backup
