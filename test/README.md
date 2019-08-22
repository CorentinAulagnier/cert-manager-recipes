# cert-manager quick tests

## Tests

### These tests are testing :
- selfsigned issuer creation
- issuer creation
- clusterissuer creation

- certificate creation from selfsigned issuer
- certificate creation from issuer
- certificate creation from clusterissuer

### Comming soon :
- certificate creation with selfsigned from Ingress
- certificate creation with issuer from Ingress
- certificate creation with clusterissuer from Ingress

## Parameters
Two parameters can be modified in the bash file :
- TEST_NAMESPACE: specify the namespace for tests
- COMMON_NAME: the CN that are inside the certificates
- SLEEP: waiting time between certificate and secret creation


## Start
> sh test.sh


