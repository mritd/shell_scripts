#!/bin/bash

yum update -y 

yum install -y nc crontabs

curl  https://get.acme.sh | bash

mkdir -p /home/www

docker run -dt --name acme -p 80:80 -v /home/www:/usr/share/nginx/html nginx:1.10.1-alpine

~/.acme.sh/acme.sh  --issue -d mritd.me -d www.mritd.me -w /tmp/acme --force

docker rm -f acme

~/.acme.sh/acme.sh  --installcert -d mritd.me -d www.mritd.me \
                    --keypath /etc/nginx/ssl/mritd.me.key \
                    --certpath /etc/nginx/ssl/mritd.me.cer \
                    --reloadcmd "cd /root/docker/mritd && docker-compose restart" 

~/.acme.sh/acme.sh  --upgrade  --auto-upgrade
