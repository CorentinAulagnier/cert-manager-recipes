
#####
# Test variables
#####
TEST_NAMESPACE=cert-manager-test

COMMON_NAME=COMMON_NAME_DEFAULT

#####
# Removing secrets, certificates and issuers
#####
kubectl delete secret ca-keys-secret --namespace=${TEST_NAMESPACE}
kubectl delete secret ca-keys-secret --namespace=cert-manager

kubectl delete issuer-selfsigned --namespace=${TEST_NAMESPACE}
kubectl delete issuer-ca --namespace=${TEST_NAMESPACE}
kubectl delete clusterissuer-ca

kubectl delete secret certificate-selfsigned-secret --namespace=${TEST_NAMESPACE}
kubectl delete secret certificate-cluster-ca-secret --namespace=${TEST_NAMESPACE}
kubectl delete secret certificate-ca-secret --namespace=${TEST_NAMESPACE}

echo
echo Self signed issuer test
echo

#####
# Self signed issuer test
#####

# Create a self signed issuer
kubectl create -f issuer-selfsigned.yaml --namespace=${TEST_NAMESPACE}

# Create a certificate using the self signed issuer
kubectl create -f certificate-selfsigned.yaml --namespace=${TEST_NAMESPACE}

# Verification
kubectl get secret certificate-selfsigned-secret --namespace=${TEST_NAMESPACE}

echo
echo Classic issuer test
echo

#####
# Classic issuer test
#####

# Generate a CA private key
openssl genrsa -out ca.key 2048

# Create a self signed Certificate, valid for 10yrs with the 'signing' option set
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${COMMON_NAME}" -days 3650 -reqexts v3_req -extensions v3_ca -out ca.crt

# Create a secret with the self signed Certificate, and the CA private key
kubectl create secret tls ca-keys-secret --cert=ca.crt --key=ca.key --namespace=${TEST_NAMESPACE}

# Create an issuer using the previous secret
kubectl create -f issuer-ca.yaml --namespace=${TEST_NAMESPACE}

# Create a certificate using the classic issuer
kubectl create -f certificate-ca.yaml --namespace=${TEST_NAMESPACE}

# Verification
kubectl get secret certificate-ca-secret --namespace=${TEST_NAMESPACE}

echo
echo Cluster issuer test
echo

#####
# Cluster issuer test
#####

# Generate a cluster CA private key
openssl genrsa -out ca.key 2048

# Create a self signed Certificate, valid for 10yrs with the 'signing' option set
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${COMMON_NAME}" -days 3650 -reqexts v3_req -extensions v3_ca -out ca.crt

# Create a secret with the self signed Certificate, and the CA private key
# The secret must be in the cert-manager namespace
kubectl create secret tls ca-keys-secret --cert=ca.crt --key=ca.key --namespace=cert-manager

# Create a cluster issuer using the previous secret
kubectl create -f clusterIssuer-ca.yaml

# Create a certificate using the classic issuer
kubectl create -f certificate-cluster-ca.yaml --namespace=${TEST_NAMESPACE}

# Verification
kubectl get secret certificate-cluster-ca-secret --namespace=${TEST_NAMESPACE}

echo
echo End test
echo

# Removing CA key and cert file
rm ca.key ca.crt



















