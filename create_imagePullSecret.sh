#!/bin/bash

REGISTRY_TOKEN=`sudo cat ~/.docker/config.json | base64 | tr -d '\n'`
REGISTRY_ADDRESS=$1

if [ "" == $REGISTRY_ADDRESS ]; then
    echo -e "\033[31mError: REGISTRY_ADDRESS is blank!\033[0m"
    exit 1
fi


tee imagePullSecret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $REGISTRY_ADDRESS 
  namespace: default
data:
  .dockerconfigjson: $REGISTRY_TOKEN
type: kubernetes.io/dockerconfigjson
EOF
kubectl create -f imagePullSecret.yaml
kubectl patch serviceaccounts default -p "{\"imagePullSecrets\":[{\"name\":\"$REGISTRY_ADDRESS\"}]}"
