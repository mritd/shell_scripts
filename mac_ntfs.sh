#!/bin/bash

brew cask install osxfuse
brew install ntfs-3g

sudo mv /sbin/mount_ntfs /sbin/mount_ntfs.bak
sudo ln -s /usr/local/bin/ntfs-3g /sbin/mount_ntfs
