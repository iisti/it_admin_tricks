# How to sync Git repository into Kubernetes pod

## Deploy

* Prerequisite: Amazon EKS with EBS CSI driver installed.

1. Change the properties in the yaml to fit your use case.
1. Deploy the [git-sync.yaml](git-sync.yaml) manifest with command below.

    ~~~sh
    kubectl -n git-sync-test apply -f git-sync.yaml
    ~~~
