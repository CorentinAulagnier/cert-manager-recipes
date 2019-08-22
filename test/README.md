# cert-manager quick tests

## Tests
These tests are testing :
- selfsigned issuer creation
- issuer creation
- clusterissuer creation

- certificate creation from selfsigned issuer
- certificate creation from issuer
- certificate creation from clusterissuer

- certificate creation with selfsigned from Ingress
- certificate creation with issuer from Ingress
- certificate creation with clusterissuer from Ingress

## Parameters
Many variables can be modified in the bash file :
- TEST_NAMESPACE: specify the namespace for tests.
- COMMON_NAME: the CN that are inside the certificates.
- SLEEP: waiting time between certificate and secret creation.

- CERT_FOLDER: the folder where certificates are stored.
- ISSUER_FOLDER: the folder where issuer are stored.
- INGRESS_FOLDER: the folder where ingress are stored.

## Start
> sh test.sh


