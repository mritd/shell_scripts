#!/bin/bash
yum update -y
yum install tmux wget lrzsz vim net-tools zsh bind-utils yum-utils ctags -y
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

