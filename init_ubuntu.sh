#!/bin/bash

set -e

TZ='Asia/Shanghai'
OZ_DOWNLOAD_URL='https://github.com/robbyrussell/oh-my-zsh.git'
OZ_CONFIG_DOWNLOAD_URL='https://git.io/fh9U2'
OZ_SYNTAX_HIGHLIGHTING_DOWNLOAD_URL='https://github.com/zsh-users/zsh-syntax-highlighting.git'
VIM_CONFIG_DOWNLOAD_URL='https://git.io/fh9rI'
VIM_PLUGINS_DOWNLOAD_URL='https://git.io/fh9r3'
DOCKER_DEB="deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
DOCKER_CONFIG_DOWNLOAD_URL='https://git.io/fh9Ui'
CTOP_DOWNLOAD_URL='https://github.com/bcicen/ctop/releases/download/v0.7.2/ctop-0.7.2-linux-amd64'
DOCKER_COMPOSE_DOWNLOAD_URL="https://github.com/docker/compose/releases/download/1.23.2/docker-compose-Linux-x86_64"

if [ "$(lsb_release -cs)" == "bionic" ]; then
    for svc in 'cloud-config cloud-final cloud-init cloud-init-local'; do
        systemctl is-active --quiet ${svc} \
            && systemctl stop ${svc} \
            && systemctl disable ${svc}
    done
fi


function sysupdate(){
    apt update -y
    apt upgrade -y
    apt install wget curl vim zsh ctags git htop tzdata ipvsadm ipset -y
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
    if [ ! -d ~/.oh-my-zsh ]; then
        git clone --depth=1 ${OZ_DOWNLOAD_URL} ~/.oh-my-zsh
        git clone ${OZ_SYNTAX_HIGHLIGHTING_DOWNLOAD_URL} ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        curl -L ${OZ_CONFIG_DOWNLOAD_URL} > ~/.zshrc
        chsh -s $(grep /zsh$ /etc/shells | tail -1)
    fi
}

function config_vim(){
    curl -L ${VIM_CONFIG_DOWNLOAD_URL} > ~/.vimrc
    mkdir -p ~/.vim/pack/mritd/{start/opt}
    cd ~/.vim/pack/mritd/start
    for addr in `curl -s ${VIM_PLUGINS_DOWNLOAD_URL}`; do
       git clone ${addr}
    done
}

function install_docker(){
    apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -
    echo ${DOCKER_DEB} > /etc/apt/sources.list.d/docker.list
    apt update -y
    apt install docker-ce -y
    mv /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.list.bak
    mv /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bak
    curl -L ${DOCKER_CONFIG_DOWNLOAD_URL} > /lib/systemd/system/docker.service
    systemctl daemon-reload
    systemctl restart docker
}

function install_ctop(){
    curl -L ${CTOP_DOWNLOAD_URL} > /usr/local/bin/ctop
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
