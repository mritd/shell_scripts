#!/bin/bash
yum update -y
yum install git wget lrzsz vim net-tools zsh -y
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

