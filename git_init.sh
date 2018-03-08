#!/bin/bash

git config --global user.name mritd
git config --global user.email mritd1234@gmail.com
git config --global core.editor vim
git config --global push.default simple
git config --global core.excludesfile ~/.global_gitignore
echo ".idea" >> ~/.global_gitignore
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tonydeng/git-toolkit/master/installer.sh)"
