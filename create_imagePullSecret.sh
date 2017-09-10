#!/bin/bash

REGISTRY_TOKEN=`sudo cat ~/.docker/config.json | base64 | tr -d '\n'`

tee imagePullSecret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: reg.domain.com 
  namespace: default
data:
  .dockerconfigjson: $REGISTRY_TOKEN
type: kubernetes.io/dockerconfigjson
EOF
kubectl create -f imagePullSecret.yaml
kubectl patch serviceaccounts default -p '{"imagePullSecrets":[{"name":"reg.domain.com"}]}'
