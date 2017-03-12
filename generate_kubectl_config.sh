#!/bin/bash

KUBE_API_SERVER=$1
CERT_DIR=${CERT_DIR-"."}

kubectl config set-cluster default-cluster --server=https:/${KUBE_API_SERVER} \
    --certificate-authority=${CERT_DIR}/ca.pem 

kubectl config set-credentials default-admin \
    --certificate-authority=${CERT_DIR}/ca.pem \
    --client-key=${CERT_DIR}/admin-key.pem \
    --client-certificate=${CERT_DIR}/admin.pem      

kubectl config set-context default-system --cluster=default-cluster --user=default-admin
kubectl config use-context default-system
