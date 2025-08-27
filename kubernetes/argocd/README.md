# ArgoCD tricks

## ArgoCD installation

* Prerequisites Helm

    ~~~sh
    helm version
        version.BuildInfo{Version:"v3.15.2", GitCommit:"1a500d5625419a524fdae4b33de351cc4f58ec35", GitTreeState:"clean", GoVersion:"go1.22.4"}
    ~~~

* Add repository and check versions

    ~~~sh
    helm repo add argo https://argoproj.github.io/argo-helm

    helm search repo argo
        NAME                            CHART VERSION   APP VERSION     DESCRIPTION
        argo/argo                       1.0.0           v2.12.5         A Helm chart for Argo Workflows
        argo/argo-cd                    7.6.1           v2.12.3         A Helm chart for Argo CD, a declarative, GitOps...
        argo/argo-ci                    1.0.0           v1.0.0-alpha2   A Helm chart for Argo-CI
        argo/argo-events                2.4.8           v1.9.2          A Helm chart for Argo Events, the event-driven ...
        argo/argo-lite                  0.1.0                           Lighweight workflow engine for Kubernetes
        argo/argo-rollouts              2.37.7          v1.7.2          A Helm chart for Argo Rollouts
        argo/argo-workflows             0.42.2          v3.5.10         A Helm chart for Argo Workflows
        argo/argocd-applicationset      1.12.1          v0.4.1          A Helm chart for installing ArgoCD ApplicationSet
        argo/argocd-apps                2.0.1                           A Helm chart for managing additional Argo CD Ap...
        argo/argocd-image-updater       0.11.0          v0.14.0         A Helm chart for Argo CD Image Updater, a tool ...
        argo/argocd-notifications       1.8.1           v1.2.1          A Helm chart for ArgoCD notifications, an add-o...
    ~~~

* argocd_values.yaml. Add read-only SSH key. Change repository names and URLs.

    ~~~yaml
    server:
      extraArgs:
        # TLS is handled by loadbalancer
        - --insecure
      resources:
        limits:
          cpu: 500m
          memory: 128Mi
        requests:
          cpu: 50m
          memory: 64Mi
      ingress:
        enabled: false
    controller:
      resources:
        limits:
          cpu: 500m
          memory: 512Mi
        requests:
          cpu: 250m
          memory: 256Mi
    dex:
      resources:
        limits:
          cpu: 50m
          memory: 64Mi
        requests:
          cpu: 10m
          memory: 32Mi
    redis:
      resources:
        limits:
          cpu: 200m
          memory: 128Mi
        requests:
          cpu: 100m
          memory: 64Mi
    #configs:
    # # Repos and credentials can be added via ArgoCD CLI
    # argocd login https://argocd.subdomain.domain.com
    # argocd repo add git@github.com:user/repo.git \
    #    --ssh-private-key-path <ssh_priv_key> \
    #    --name <repo_name>
    #credentialTemplates:
    #    ssh-creds-argocd-apps:
    #    url: 'git@github.com:ORG/argocd-apps.git'
    #    sshPrivateKey: |
    #        -----BEGIN OPENSSH PRIVATE KEY-----
    #        ...
    #        -----END OPENSSH PRIVATE KEY-----
    #repositories:
    #    sophia:
    #    type: git
    #    name: argocd-apps-k8s
    #    url: 'git@github.com:ORG/argocd-apps.git'
    #    insecure: "true"
    ~~~

* Install ArgoCD

    ~~~sh
    kubectl create namespace argocd

    helm install --values argocd_values.yaml argocd argo/argo-cd -n argocd
    ~~~

  * Check admin password with the instructions given after installation.

* In this example the Kubernetes ingress controller is Traefik, so we'll create traefik ingress resource `argocd-ingress-traefik.yaml`

    ~~~yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
    labels:
        app.kubernetes.io/name: argocd-server-ingress
        app.kubernetes.io/part-of: argocd
    name: argocd-server-ingress
    namespace: argocd
    spec:
    rules:
        - host: argocd.example.com
        http:
            paths:
            - backend:
                service:
                    name: argocd-server
                    port:
                    name: http
                path: /
                pathType: Prefix
    ~~~
