#!/bin/bash

if [ "$1" = "" ]; then
    echo "Error: image Name is blank!"
    exit 1
fi

allImages=($1)

for imageName in allImages; do
    docker save $imageName > `echo $imageName | tr '/' '_' | tr ':' '_'`.tar;
done
