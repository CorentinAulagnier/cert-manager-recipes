#!/bin/bash

#####
# delete CRDs
#####

kubectl get crds | grep certmanager | awk '{print $1}' | xargs -I '{}' kubectl delete crd '{}'

#####
# delete cert-manager
#####

helm delete --purge cert-manager

#####
# install CRDs
#####

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml

#####
# install cert-manager v10
#####

helm install --name cert-manager --namespace cert-manager --version v0.10.0-alpha.0  jetstack/cert-manager --set webhook.enabled=false

#####
# start tests
#####

sh ./test.sh



