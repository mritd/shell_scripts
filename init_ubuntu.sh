#!/bin/bash

set -e

TZ='Asia/Shanghai'
OS_RELEASE="$(lsb_release -cs)"
SOURCES_LIST_URL='https://git.io/fhQ6B'
DOCKER_LIST_URL='https://git.io/fhQ68'
OZ_DOWNLOAD_URL='https://github.com/robbyrussell/oh-my-zsh.git'
OZ_CONFIG_DOWNLOAD_URL='https://git.io/fh9U2'
OZ_SYNTAX_HIGHLIGHTING_DOWNLOAD_URL='https://github.com/zsh-users/zsh-syntax-highlighting.git'
VIM_CONFIG_DOWNLOAD_URL='https://git.io/fh9rI'
VIM_PLUGINS_DOWNLOAD_URL='https://git.io/fh9r3'
DOCKER_CONFIG_DOWNLOAD_URL='https://git.io/fh9Ui'
CTOP_DOWNLOAD_URL='https://github.com/bcicen/ctop/releases/download/v0.7.2/ctop-0.7.2-linux-amd64'
DOCKER_COMPOSE_DOWNLOAD_URL="https://github.com/docker/compose/releases/download/1.23.2/docker-compose-Linux-x86_64"

function disable_cloudinit(){
    for svc in 'cloud-config cloud-final cloud-init cloud-init-local'; do
        systemctl is-active --quiet ${svc} \
            && systemctl stop ${svc} \
            && systemctl disable ${svc}
    done
}

function setlocale(){
    locale-gen --purge en_US.UTF-8 zh_CN.UTF-8
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale
    echo 'LANGUAGE="en_US:en"' >> /etc/default/locale
}

function sysupdate(){
    mv /etc/apt/sources.list /etc/apt/sources.list.old
    curl -sL ${SOURCES_LIST_URL} | sed "s@{{OS_RELEASE}}@${OS_RELEASE}@gi" > /etc/apt/sources.list
    apt update -y
    apt upgrade -y
    apt install -y apt-transport-https ca-certificates software-properties-common \
        wget curl vim zsh ctags git htop tzdata conntrack ipvsadm ipset stress sysstat
}

function settimezone(){
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
    echo ${TZ} > /etc/timezone
}

function install_ohmyzsh(){
    if [ ! -d ~/.oh-my-zsh ]; then
        git clone --depth=1 ${OZ_DOWNLOAD_URL} ~/.oh-my-zsh
        git clone ${OZ_SYNTAX_HIGHLIGHTING_DOWNLOAD_URL} ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        curl -sL ${OZ_CONFIG_DOWNLOAD_URL} > ~/.zshrc
        chsh -s $(grep /zsh$ /etc/shells | tail -1)
    fi
}

function config_vim(){
    curl -sL ${VIM_CONFIG_DOWNLOAD_URL} > ~/.vimrc
    mkdir -p ~/.vim/pack/plugins/{start,opt}
    cd ~/.vim/pack/plugins/start
    for addr in `curl -sL ${VIM_PLUGINS_DOWNLOAD_URL}`; do
        echo "git clone => ${addr}"
        git clone ${addr} > /dev/null 2>&1
    done
}

function install_docker(){
    curl -sL ${DOCKER_LIST_URL} | sed "s@{{OS_RELEASE}}@${OS_RELEASE}@gi" > /etc/apt/sources.list.d/docker.list
    curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -
    apt update -y
    apt install docker-ce -y
    mv /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.list.bak
    mv /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bak
    curl -sL ${DOCKER_CONFIG_DOWNLOAD_URL} > /lib/systemd/system/docker.service
    systemctl daemon-reload
    systemctl restart docker
}

function install_ctop(){
    curl -sL ${CTOP_DOWNLOAD_URL} > /usr/local/bin/ctop
    chmod +x /usr/local/bin/ctop
}

function install_dc(){
    curl -sL ${DOCKER_COMPOSE_DOWNLOAD_URL} > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

disable_cloudinit
setlocale
sysupdate
settimezone
config_vim
install_ohmyzsh
install_docker
install_ctop
install_dc
