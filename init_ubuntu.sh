#!/bin/bash

set -e

function sysupdate(){
    apt update -y
    apt upgrade -y
    apt install wget curl vim zsh ctags git htop -y
}

function setlocale(){
    locale-gen --purge en_US.UTF-8 zh_CN.UTF-8
    echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale
}

function install_ohmyzsh(){
    git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    wget https://mritdftp.b0.upaiyun.com/files/config/ohmyzsh.tar.gz
    tar -zxvf ohmyzsh.tar.gz -C ~ && rm -f ohmyzsh.tar.gz
    chsh -s $(grep /zsh$ /etc/shells | tail -1)
}

function config_vim(){
    wget https://mritdftp.b0.upaiyun.com/files/config/vim.tar.gz
    tar -zxvf vim.tar.gz -C ~ && rm -f vim.tar.gz
}

function install_docker(){
    apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -
    echo "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    apt update -y
    apt install docker-ce -y
    mv /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.list.bak
    mv /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bak
    wget https://mritdftp.b0.upaiyun.com/files/config/docker.tar.gz
    tar -zxvf docker.tar.gz -C /lib/systemd/system && rm -f docker.tar.gz
    systemctl daemon-reload
    systemctl restart docker
}

function install_ctop(){
    wget https://mritdftp.b0.upaiyun.com/files/ctop/ctop-0.7-linux-amd64 -O /usr/local/bin/ctop
    chmod +x /usr/local/bin/ctop
}

function install_dc(){
    curl -L https://get.daocloud.io/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

sysupdate
setlocale
config_vim
install_ohmyzsh
install_docker
install_ctop
install_dc
