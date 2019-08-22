#!/bin/bash

#####
# Test variables
#####
TEST_NAMESPACE=cert-manager-test

COMMON_NAME=COMMON_NAME_DEFAULT

SLEEP=2

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
kubectl create -f issuer-selfsigned.yaml --namespace=${TEST_NAMESPACE}

# Create a certificate using the self signed issuer
kubectl create -f certificate-selfsigned.yaml --namespace=${TEST_NAMESPACE}

echo
echo Verification
echo

sleep ${SLEEP}
kubectl get secret certificate-selfsigned-secret --namespace=${TEST_NAMESPACE}


#####
# Classic issuer test
#####

echo
echo "###############"
echo Classic issuer test
echo

# Generate a CA private key
openssl genrsa -out ca.key 2048

# Create a self signed Certificate, valid for 10yrs with the 'signing' option set
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${COMMON_NAME}" -days 3650 -reqexts v3_req -extensions v3_ca -out ca.crt

# Create a secret with the self signed Certificate, and the CA private key
kubectl create secret tls ca-keys-secret --cert=ca.crt --key=ca.key --namespace=${TEST_NAMESPACE}
echo

# Create an issuer using the previous secret
kubectl create -f issuer-ca.yaml --namespace=${TEST_NAMESPACE}

# Create a certificate using the classic issuer
kubectl create -f certificate-ca.yaml --namespace=${TEST_NAMESPACE}

echo
echo Verification
echo

sleep ${SLEEP}
kubectl get secret certificate-ca-secret --namespace=${TEST_NAMESPACE}

#####
# Cluster issuer test
#####

echo
echo "###############"
echo Cluster issuer test
echo

# Generate a cluster CA private key
openssl genrsa -out ca.key 2048

# Create a self signed Certificate, valid for 10yrs with the 'signing' option set
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${COMMON_NAME}" -days 3650 -reqexts v3_req -extensions v3_ca -out ca.crt

# Create a secret with the self signed Certificate, and the CA private key
# The secret must be in the cert-manager namespace
kubectl create secret tls cluster-ca-keys-secret --cert=ca.crt --key=ca.key --namespace=cert-manager
echo

# Create a cluster issuer using the previous secret
kubectl create -f clusterIssuer-ca.yaml

# Create a certificate using the classic issuer
kubectl create -f certificate-cluster-ca.yaml --namespace=${TEST_NAMESPACE}

echo
echo Verification
echo

sleep ${SLEEP}
kubectl get secret certificate-cluster-ca-secret --namespace=${TEST_NAMESPACE}
echo

deleteRessources

















