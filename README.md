# cert-manager-recipes
Recipes for cert-manager ressources

## Note
> CA = certificate authority

# Ressources

## Issuer
An Issuer is a way to sign a certificat. This Issuer is only accessible in one namespace. If you want an Issuer accessible from the entire cluster, you must use a ClusterIssuer.
You can choose to :
- self-sign : the keys present in the certificate are the same as those used to sign it (not recommended)
- use the issuer as a CA : the given key will sign all certificates
- forward the request to another CA : you must give informations about this external CA (recommended)

## ClusterIssuer
A ClusterIssuer is an Issuer accessible from all cluster's namespaces.
> When referencing a **Secret** resource in **ClusterIssuer** resources the Secret needs to be in the same namespace as the cert-manager controller pod. You can optionally override this by using the **--cluster-resource-namespace** argument to the controller.

## Certificate
A Certificate is a specification indicating which Secret will store your certificate/private key, what information will be in your certificate and which Issuer (or ClusterIssuer) will sign your certificate.

## Example
```
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: my-certificate
spec:
  secretName: certificate-and-key-secret #TLS Secret where cert and key are stored
  duration: 24h
  renewBefore: 12h
  commonName: app.name.com  #Application DNS name
  issuerRef:
    name: my-issuer #Issuer reference
    kind: Issuer
--
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  name: my-issuer
spec:
  ca:
    secretName: issuer-keys #Key used to sign certificates
```

# Links

## Cert-manager repo
https://github.com/jetstack/cert-manager

## Documentation
https://cert-manager.readthedocs.io/en/latest/index.html

## Helm chart
https://github.com/helm/charts/tree/master/stable/cert-manager

