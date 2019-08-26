#!/bin/bash

kubectl get crds | grep certmanager | awk '{print $1}' | xargs -I '{}' kubectl delete crd '{}'

helm delete --purge cert-manager

sleep 10

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml

sleep 2

helm install --name cert-manager --namespace cert-manager --version v0.10.0-alpha.0  jetstack/cert-manager --set webhook.enabled=false

sleep 10

sh ./test.sh



