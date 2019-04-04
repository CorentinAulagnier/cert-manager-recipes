# cert-manager-recipes
Recipes for cert-manager ressources

## Cert-manager repo
https://github.com/jetstack/cert-manager

## Documentation
https://cert-manager.readthedocs.io/en/latest/index.html

## Helm chart
https://github.com/helm/charts/tree/master/stable/cert-manager

## Note
> When referencing a **Secret** resource in **ClusterIssuer** resources the Secret needs to be in the same namespace as the cert-manager controller pod. You can optionally override this by using the **--cluster-resource-namespace** argument to the controller.
