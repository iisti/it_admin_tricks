# Kustomize: Example of replacing a hostname in ingress configuration

1. One can create a file to set ArgoCD hostname with commands below. Remember to change the value to desired hostname.

    ~~~sh
    cat <<EOF >./set_hostname_argocd.yaml
    - op: replace
      path: /spec/rules/0/host
      value: argocd.newdomain.com
    EOF
    ~~~

1. View the kustomized ingress

    ~~~sh
    kubectl kustomize ./
    ~~~

1. Apply the kustomized ingress

    ~~~sh
    kubectl kustomize ./ | kubectl apply -f --
    ~~~
