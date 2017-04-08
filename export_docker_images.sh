#!/bin/bash
for imageName in `docker images | grep -v "REPOSITORY" | awk '{print $1":"$2}'`;do docker save $imageName > `echo $imageName | tr '/' '_' | tr ':' '_'`.tar ; done
