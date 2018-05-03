#!/bin/bash

set -e

TZ='Asia/Shanghai'
OZ_DOWNLOAD_URL='https://github.com/robbyrussell/oh-my-zsh.git'
OZ_CONFIG_DOWNLOAD_URL='https://mritdftp.b0.upaiyun.com/files/config/ohmyzsh.tar.gz'
VIM_CONFIG_DOWNLOAD_URL='https://mritdftp.b0.upaiyun.com/files/config/vim.tar.gz'
DOCKER_DEB="deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
DOCKER_CONFIG_DOWNLOAD_URL='https://mritdftp.b0.upaiyun.com/files/config/docker.tar.gz'
CTOP_DOWNLOAD_URL='https://mritdftp.b0.upaiyun.com/files/ctop/ctop-0.7.1-linux-amd64'
DOCKER_COMPOSE_DOWNLOAD_URL="https://get.daocloud.io/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m`"


function sysupdate(){
    apt update -y
    apt upgrade -y
    apt install wget curl vim zsh ctags git htop tzdata -y
}

function setlocale(){
    locale-gen --purge en_US.UTF-8 zh_CN.UTF-8
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale
    echo 'LANGUAGE="en_US:en"' >> /etc/default/locale
}

function settimezone(){
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
    echo ${TZ} > /etc/timezone
}

function install_ohmyzsh(){
    git clone --depth=1 ${OZ_DOWNLOAD_URL} ~/.oh-my-zsh
    wget ${OZ_CONFIG_DOWNLOAD_URL}
    tar -zxvf ohmyzsh.tar.gz -C ~ && rm -f ohmyzsh.tar.gz
    chsh -s $(grep /zsh$ /etc/shells | tail -1)
}

function config_vim(){
    wget ${VIM_CONFIG_DOWNLOAD_URL}
    tar -zxvf vim.tar.gz -C ~ && rm -f vim.tar.gz
}

function install_docker(){
    apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -
    echo ${DOCKER_DEB} > /etc/apt/sources.list.d/docker.list
    apt update -y
    apt install docker-ce -y
    mv /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.list.bak
    mv /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bak
    wget ${DOCKER_CONFIG_DOWNLOAD_URL}
    tar -zxvf docker.tar.gz -C /lib/systemd/system && rm -f docker.tar.gz
    systemctl daemon-reload
    systemctl restart docker
}

function install_ctop(){
    wget ${CTOP_DOWNLOAD_URL} -O /usr/local/bin/ctop
    chmod +x /usr/local/bin/ctop
}

function install_dc(){
    curl -L ${DOCKER_COMPOSE_DOWNLOAD_URL} > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

sysupdate
setlocale
settimezone
config_vim
install_ohmyzsh
install_docker
install_ctop
install_dc
