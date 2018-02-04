#!/bin/bash

git config --global user.name mritd
git config --global user.email mritd1234@gmail.com
git config --global core.editor vim
git config --global push.default simple
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tonydeng/git-toolkit/master/installer.sh)"
