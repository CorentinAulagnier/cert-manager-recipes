#!/bin/bash

#####
# Test variables
#####
TEST_NAMESPACE=cert-manager-test

COMMON_NAME=COMMON_NAME_DEFAULT

SLEEP=2

CERTIFICATE_FOLDER="./certificate/"
ISSUER_FOLDER="./issuer/"
INGRESS_FOLDER="./ingress/"

#####
# Removing CA key and cert file, secrets, certificates and issuers
#####

deleteRessources() 
{
	rm ca.key ca.crt									>/dev/null 2>&1

	kubectl delete secret ca-keys-secret --namespace=${TEST_NAMESPACE} 			>/dev/null 2>&1
	kubectl delete secret cluster-ca-keys-secret --namespace=cert-manager 			>/dev/null 2>&1

	kubectl delete issuer issuer-selfsigned --namespace=${TEST_NAMESPACE} 			>/dev/null 2>&1
	kubectl delete issuer issuer-ca --namespace=${TEST_NAMESPACE} 				>/dev/null 2>&1
	kubectl delete clusterissuer clusterissuer-ca						>/dev/null 2>&1

	kubectl delete certificate certificate-selfsigned --namespace=${TEST_NAMESPACE} 	>/dev/null 2>&1
	kubectl delete certificate certificate-ca --namespace=${TEST_NAMESPACE} 		>/dev/null 2>&1
	kubectl delete certificate certificate-cluster-ca --namespace=${TEST_NAMESPACE}		>/dev/null 2>&1

	kubectl delete secret certificate-selfsigned-secret --namespace=${TEST_NAMESPACE} 	>/dev/null 2>&1
	kubectl delete secret certificate-ca-secret --namespace=${TEST_NAMESPACE}		>/dev/null 2>&1
	kubectl delete secret certificate-cluster-ca-secret --namespace=${TEST_NAMESPACE}	>/dev/null 2>&1

	kubectl delete secret ingress-selfsigned-issuer-secret --namespace=${TEST_NAMESPACE}	>/dev/null 2>&1
	kubectl delete secret ingress-issuer-secret --namespace=${TEST_NAMESPACE}		>/dev/null 2>&1
	kubectl delete secret ingress-clusterissuer-secret --namespace=${TEST_NAMESPACE}	>/dev/null 2>&1

	kubectl delete ingress ingress-selfsigned-issuer --namespace=${TEST_NAMESPACE}		>/dev/null 2>&1
	kubectl delete ingress ingress-issuer --namespace=${TEST_NAMESPACE}			>/dev/null 2>&1
	kubectl delete ingress ingress-clusterissuer --namespace=${TEST_NAMESPACE}		>/dev/null 2>&1

}

deleteRessources

#####
# Self signed issuer test
#####

echo
echo "###############"
echo Self signed issuer test
echo

# Create a self signed issuer
kubectl create -f ${ISSUER_FOLDER}issuer-selfsigned.yaml --namespace=${TEST_NAMESPACE}

# Create a certificate using the self signed issuer
kubectl create -f ${CERTIFICATE_FOLDER}certificate-selfsigned.yaml --namespace=${TEST_NAMESPACE}

# Create an ingress using certificate and the selfsigned issuer
kubectl create -f ${INGRESS_FOLDER}ingress-selfsigned.yaml --namespace=${TEST_NAMESPACE}

echo
echo Verification
echo \"certificate-selfsigned-secret\" and \"ingress-selfsigned-issuer-secret\" secret must appear
echo

sleep ${SLEEP}
kubectl get secret certificate-selfsigned-secret ingress-selfsigned-issuer-secret --namespace=${TEST_NAMESPACE}


#####
# Classic issuer test
#####

echo
echo "###############"
echo Classic issuer test
echo

# Generate a CA private key
openssl genrsa -out ca.key 2048	>/dev/null 2>&1

# Create a self signed Certificate, valid for 10yrs with the 'signing' option set
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${COMMON_NAME}" -days 3650 -reqexts v3_req -extensions v3_ca -out ca.crt	>/dev/null 2>&1

# Create a secret with the self signed Certificate, and the CA private key
kubectl create secret tls ca-keys-secret --cert=ca.crt --key=ca.key --namespace=${TEST_NAMESPACE}
echo

# Create an issuer using the previous secret
kubectl create -f ${ISSUER_FOLDER}issuer-ca.yaml --namespace=${TEST_NAMESPACE}

# Create a certificate using the classic issuer
kubectl create -f ${CERTIFICATE_FOLDER}certificate-ca.yaml --namespace=${TEST_NAMESPACE}

# Create an ingress using certificate and the classic issuer
kubectl create -f ${INGRESS_FOLDER}ingress-issuer.yaml --namespace=${TEST_NAMESPACE}

echo
echo Verification
echo \"certificate-ca-secret\" and \"ingress-issuer-secret\" secret must appear
echo

sleep ${SLEEP}
kubectl get secret certificate-ca-secret ingress-issuer-secret --namespace=${TEST_NAMESPACE}

#####
# Cluster issuer test
#####

echo
echo "###############"
echo Cluster issuer test
echo

# Generate a cluster CA private key
openssl genrsa -out ca.key 2048	>/dev/null 2>&1

# Create a self signed Certificate, valid for 10yrs with the 'signing' option set
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${COMMON_NAME}" -days 3650 -reqexts v3_req -extensions v3_ca -out ca.crt	>/dev/null 2>&1

# Create a secret with the self signed Certificate, and the CA private key
# The secret must be in the cert-manager namespace
kubectl create secret tls cluster-ca-keys-secret --cert=ca.crt --key=ca.key --namespace=cert-manager
echo

# Create a cluster issuer using the previous secret
kubectl create -f ${ISSUER_FOLDER}clusterIssuer-ca.yaml

# Create a certificate using the cluster issuer
kubectl create -f ${CERTIFICATE_FOLDER}certificate-cluster-ca.yaml --namespace=${TEST_NAMESPACE}

# Create an ingress using certificate and the cluster issuer
kubectl create -f ${INGRESS_FOLDER}ingress-clusterissuer.yaml --namespace=${TEST_NAMESPACE}

echo
echo Verification
echo \"certificate-cluster-ca-secret\" and \"ingress-clusterissuer-secret\" secret must appear
echo

sleep ${SLEEP}
kubectl get secret certificate-cluster-ca-secret ingress-clusterissuer-secret  --namespace=${TEST_NAMESPACE}
echo

deleteRessources

