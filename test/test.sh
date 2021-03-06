#!/bin/bash

#####
# Test variables
#####
TEST_NAMESPACE=cert-manager-test

COMMON_NAME=COMMON_NAME_DEFAULT

SLEEP=5

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

CERTIFICATE_FOLDER=$SCRIPTPATH"/certificate/"
ISSUER_FOLDER=$SCRIPTPATH"/issuer/"
INGRESS_FOLDER=$SCRIPTPATH"/ingress/"

#####
# Removing CA key and cert file, secrets, certificates and issuers
#####

deleteRessources() 
{
	rm ca.key ca.crt											>/dev/null 2>&1

	kubectl delete secret ca-keys-secret --namespace=${TEST_NAMESPACE} 					>/dev/null 2>&1
	kubectl delete secret cluster-ca-keys-secret --namespace=cert-manager 					>/dev/null 2>&1

	kubectl delete -f ${ISSUER_FOLDER}issuer-selfsigned.yaml --namespace=${TEST_NAMESPACE} 			>/dev/null 2>&1
	kubectl delete -f ${ISSUER_FOLDER}issuer-ca.yaml --namespace=${TEST_NAMESPACE} 				>/dev/null 2>&1
	kubectl delete -f ${ISSUER_FOLDER}clusterIssuer-ca.yaml							>/dev/null 2>&1

	kubectl delete -f ${CERTIFICATE_FOLDER}certificate-selfsigned.yaml --namespace=${TEST_NAMESPACE} 	>/dev/null 2>&1
	kubectl delete -f ${CERTIFICATE_FOLDER}certificate-ca.yaml --namespace=${TEST_NAMESPACE} 		>/dev/null 2>&1
	kubectl delete -f ${CERTIFICATE_FOLDER}certificate-cluster-ca.yaml --namespace=${TEST_NAMESPACE}	>/dev/null 2>&1

	kubectl delete -f ${INGRESS_FOLDER}ingress-selfsigned.yaml --namespace=${TEST_NAMESPACE}		>/dev/null 2>&1
	kubectl delete -f ${INGRESS_FOLDER}ingress-issuer.yaml --namespace=${TEST_NAMESPACE}			>/dev/null 2>&1
	kubectl delete -f ${INGRESS_FOLDER}ingress-clusterissuer.yaml --namespace=${TEST_NAMESPACE}		>/dev/null 2>&1

	kubectl delete secret certificate-selfsigned-secret --namespace=${TEST_NAMESPACE} 			>/dev/null 2>&1
	kubectl delete secret certificate-ca-secret --namespace=${TEST_NAMESPACE}				>/dev/null 2>&1
	kubectl delete secret certificate-cluster-ca-secret --namespace=${TEST_NAMESPACE}			>/dev/null 2>&1

	kubectl delete secret ingress-selfsigned-issuer-secret --namespace=${TEST_NAMESPACE}			>/dev/null 2>&1
	kubectl delete secret ingress-issuer-secret --namespace=${TEST_NAMESPACE}				>/dev/null 2>&1
	kubectl delete secret ingress-clusterissuer-secret --namespace=${TEST_NAMESPACE}			>/dev/null 2>&1


}


deleteRessources

# Test namespace creation
kubectl create ns ${TEST_NAMESPACE}	>/dev/null 2>&1

#####
# Self signed issuer test
#####

echo
echo "###############"
echo "# Self signed issuer test"
echo

# Create a self signed issuer
kubectl create -f ${ISSUER_FOLDER}issuer-selfsigned.yaml --namespace=${TEST_NAMESPACE}

# Create a certificate using the self signed issuer
kubectl create -f ${CERTIFICATE_FOLDER}certificate-selfsigned.yaml --namespace=${TEST_NAMESPACE}

# Create an ingress using certificate and the selfsigned issuer
kubectl create -f ${INGRESS_FOLDER}ingress-selfsigned.yaml --namespace=${TEST_NAMESPACE}

echo
echo "# Verification"
echo \"certificate-selfsigned-secret\" and \"ingress-selfsigned-issuer-secret\" secrets must appear
echo

sleep ${SLEEP}
kubectl get secret certificate-selfsigned-secret ingress-selfsigned-issuer-secret --namespace=${TEST_NAMESPACE}


#####
# Classic issuer test
#####

echo
echo "###############"
echo "# Classic issuer test"
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
echo "# Verification"
echo \"certificate-ca-secret\" and \"ingress-issuer-secret\" secrets must appear
echo

sleep ${SLEEP}
kubectl get secret certificate-ca-secret ingress-issuer-secret --namespace=${TEST_NAMESPACE}

#####
# Cluster issuer test
#####

echo
echo "###############"
echo "# Cluster issuer test"
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
echo "# Verification"
echo \"certificate-cluster-ca-secret\" and \"ingress-clusterissuer-secret\" secrets must appear
echo

sleep ${SLEEP}
kubectl get secret certificate-cluster-ca-secret ingress-clusterissuer-secret  --namespace=${TEST_NAMESPACE}
echo

deleteRessources

