# Deploy PrivateBin to Kuberenetes

## Configure

argocd_privatebin.yaml

~~~yaml
source:
    path: kubernetes/apps/privatebin
    repoURL: "git@github.com:iisti/it_admin_tricks_private.git"
~~~
