# Create k3s Kubernetes cluster in Hetzner Cloud

## Created infrastructure

The infrastructure below will be created in Hetzner Cloud.

* User -> Load Balancer -> k3s Node(s) -> Pods

### Components

* Ingress Controller
  * Traefik
* Monitoring
  * Prometheus
  * Grafana
* Continous Deployment
  * ArgoCD
* Pods / Apps
  * PrivateBin = For sending sensitive data

## Prerequisites

### Installed on the local machine

* kubectl
* kustomize
* helm
* argocd CLI
* terraform
* kubectx (optional)

### Configuration files that are not in this repository

* Traefik
* ArgoCD
* SSH keys for accessing Kubernetes nodes and GitHub repos

### Hetzner

* Cloud project and API key configured via GUI console.cloud.hetzner.com
* Domain and DNS API key
* This example uses GCS (Google Cloud Storage) as Terraform backend. Of course one can use whatever Terraform compatible backend.

#### Prerequisites configuration

1. Create Hetzner account
1. Create Project in <https://console.hetzner.com/projects>
    * We'll use name `infra-project-01` in this example.
1. Create API key via Hetzner cloud
    1. Go to the created project and click Security
    1. API tokens -> Generate API token, Read & Write permissions
1. Copy template configuration with the script below.
    1. Create directory for an infrastructure project, i.e. `my-infra-projects/infra-project-01`
        * Notice, `infra-project-01` is your project name.
    1. Copy hcloud_modules directory and files under infra-template-01 into `my-infra-projects`. Rename infra-template-01 sub directories to your project name.

        ~~~sh
        ### VARIABLES
        project="infra-project-01"
        project_root_dir="my-infra-projects"
        git_repo_full_path="$HOME/scripts/it_admin_tricks_private/kubernetes/hetzner"
        ~~~

        ~~~sh
        # Create directories
        cd "$git_repo_full_path"
        mkdir "$project_root_dir"
        
        # Copy terraform template files
        cp -r modules "$project_root_dir"
        cp -r infra-template-01 "$project_root_dir"/"$project"
        cd "$project_root_dir"
        ~~~

    * The directory structure should be something like

      ~~~sh
      .
      └── my-infra-projects
          ├── infra-project-01
          │   ├── dns
          │   │   ├── dns_records.yaml
          │   │   ├── main.tf
          │   │   ├── terraform.tfvars
          │   │   └── variables.tf
          │   ├── ips
          │   │   ├── main.tf
          │   │   ├── outputs.tf
          │   │   ├── terraform.tfvars
          │   │   └── variables.tf
          │   ├── k3s
          │   │   ├── cloud-init-master.yaml
          │   │   ├── firewall.tf
          │   │   ├── https_certificates.tf
          │   │   ├── load-balancer.tf
          │   │   ├── main.tf
          │   │   ├── outputs.tf
          │   │   ├── terraform.tfvars
          │   │   └── variables.tf
          │   ├── infra-project-01-env-vars.tf-env
          │   ├── networks
          │   │   ├── main.tf
          │   │   ├── outputs.tf
          │   │   ├── terraform.tfvars
          │   │   └── variables.tf
          │   ├── sed-dns.sh
          │   ├── sed-env.sh
          │   └── ssh_keys
          │       ├── main.tf
          │       ├── ssh_keys.tf
          │       ├── terraform.tfvars
          │       └── variables.tf
          └── modules
              ├── hcloud_dns
              │   ├── main.tf
              │   └── variables.tf
              ├── hcloud_ip
              │   ├── main.tf
              │   ├── outputs.tf
              │   └── variables.tf
              ├── hcloud_network
              │   ├── main.tf
              │   ├── network.tf
              │   ├── outputs.tf
              │   └── variables.tf
              └── hcloud_vm
                  ├── main.tf
                  ├── outputs.tf
                  ├── README.md
                  └── variables.tf

      13 directories, 40 files
      ~~~

1. Generate SSH keys

    ~~~sh
    ssh-keygen -t ed25519 -C "admin@example.com"
    ~~~

1. Create `terraform.tfvars` files in `dns`, `ips`, `k3s`, `networks` and `ssh_keys` directories.

    ~~~sh
    # Go to the project directory
    cd "$git_repo_full_path"/"$project_root_dir"/"$project"

    cat > ssh_keys/terraform.tfvars << EOL
    api_token = "VAR_DNS_API_TOKEN"
    EOL

    cat > ips/terraform.tfvars << EOL
    hcloud_token = "VAR_HCLOUD_TOKEN" # VAR_PROJECT
    EOL

    cat > networks/terraform.tfvars << EOL
    hcloud_token = "VAR_HCLOUD_TOKEN" # VAR_PROJECT
    EOL

    cat > ssh_keys/terraform.tfvars << EOL
    hcloud_token = "VAR_HCLOUD_TOKEN" # VAR_PROJECT
    EOL
    ~~~

    ~~~sh
    cat > k3s/terraform.tfvars << EOL
    hcloud_token           = "VAR_HCLOUD_TOKEN" # VAR_PROJECT
    ssh_key_worker         = <<-EOT
    VAR_SSH_KEY_PRIVATE_WORKER
    EOT
    ssh_key_pub_worker     = "VAR_SSH_KEY_PUBLIC_WORKER"
    ssh_key_pub_admin      = "VAR_SSH_KEY_PUBLIC_ADMIN"
    ssh_key_pub_admin_name = "VAR_SSH_KEY_NAME_ADMIN"
    EOL
    ~~~

1. Create `infra-project-01-env-vars.tf-env` file with similar content as below.

    ~~~sh
    ######################################################
    ### VARIABLES: CREATE DIRECTORY AND FILE STRUCTURE
    ######################################################

    project="infra-project-01"
    project_root_dir="my-infra-projects"
    git_repo_full_path="$HOME/path/it_admin_tricks/kubernetes/hetzner"

    ######################################################
    ### VARIABLES: CREATE INFRASTRUCTURE WITH TERRAFORM
    ######################################################

    ### Variables: global (scope project)
    terraform_version="1.52.0"
    gcs_bucket="bucket-name"
    ssh_key_name_admin="admin@example.com"
    ssh_key_public_admin="ssh-ed25519 xxxyyywww admin@example.com"
    hcloud_token="asdfqwer1234"
    project="infra-project-01"

    ### Variables: dns
    germanbrew_hetznerdns_version="3.4.3"
    gcs_prefix_dns="dns_$project"
    dns_api_token="asdfghkj1234"

    ### Variables: ips
    vm_name_master="master01"
    ip_datacenter="fsn1-dc14"
    gcs_prefix_ips="ips_$project"

    ### Variables: k3s
    gcs_prefix_k3s="k3s_$project"
    firewall_label_master="vm=k3s-05_master01"
    ssh_key_worker_private="-----BEGIN OPENSSH PRIVATE KEY-----
    asdf
    qwer
    1234
    -----END OPENSSH PRIVATE KEY-----"
    ssh_key_pub_worker="ssh-ed25519 zxcvasdfqwer worker"
    tld_domain_name="example.com"
    sub_domain_name="infra01"

    #### master vm config
    master_ip_internal="10.0.116.5"
    vm_name_master="master01"

    base_name="infra-01"
    vm_image="debian-12"
    vm_type="ccx23"
    vm_datacenter="fsn1"
    vm_backups=false
    vm_delete_protection=false
    vm_rebuild_protection=false
    ssh_key_label="ssh_key=admin"
    network_name="kubernetes"
    private_ip="10.0.116.5"
    public_ip_label="vm=infra-01_master01"
    user_data_file="cloud-init-master.yaml"
    database_certificate_email="admin@example.com",
    vm_labels_master="infra-01_master01"
    delete_protection=false
    auto_delete=false

    ### Variables: networks
    gcs_prefix_networks="networks_$project"
    network_name="kubernetes"
    network_ip_range="10.0.116.0/23"
    subnet_ip_range="10.0.116.0/24"

    ### Variabels: ssh_keys
    gcs_prefix="ssh_keys_$project"

    ######################################################
    ### VARIABLES: WORK WITH KUBERNETES INFRASTRUCTURE
    ######################################################

    ssh_priv_key="$HOME/.ssh/id_ed25519_node_admin_key"
    argocd_priv_key="$HOME/.ssh/id_ed25519_some_key"
    argocd_app_repo_name="repo_name"
    argocd_app_repo_url_git="git@github.com:org_or_user/repo.git"
    argocd_app_demo_yaml="path_to_argocd_privatebin.yaml"
    argocd_app_demo_name="pbin"
    prometheus_ingress_yaml="path_to_prometheus_ingress.yaml"
    grafana_ingress_yaml="path_to_grafana_ingress.yaml"

    ######################################################
    ### VARIABLES AUTOMATICALLY UPDATED
    ######################################################

    k8s_env="$project"
    k8s_tld="$tld_domain_name"
    k8s_url="$sub_domain_name"
    master_ip_public="VAR_MASTER_PUBLIC_IP"
    ~~~

1. Run sed-env.sh with your configuration file to substitute the variables.

    ~~~sh
    env_var_file="$git_repo_full_path"/"$project_root_dir"/"$project"/infra-project-01-env-vars.tf-env
    ~~~

    ~~~sh
    ./sed-env.sh "$env_var_file"
    ~~~

## Instructions

The instructions are in order which they should be used.

~~~sh
source "$env_var_file"

################################################
### Create infrastructure
################################################

## Create network
cd "$git_repo_full_path"/"$project_root_dir"/"$project"/networks

terraform init
terraform apply 

## Create static IP for kubernetes master
cd "$git_repo_full_path"/"$project_root_dir"/"$project"/ips

terraform init
terraform apply

## Create admin SSH key
cd "$git_repo_full_path"/"$project_root_dir"/"$project"/ssh_keys

terraform init
terraform apply

## Create k3s
cd "$git_repo_full_path"/"$project_root_dir"/"$project"/k3s

terraform init
# Do not create LB targets otherwise there will be an error.
terraform apply -var="create_lb_targets=false"
terraform apply

## Create DNS records
cd "$git_repo_full_path"/"$project_root_dir"/"$project"
./sed-dns.sh "$env_var_file"

# env_var_file was updated with the IPs, so load it again to shell.
source "$env_var_file"

cd "$git_repo_full_path"/"$project_root_dir"/"$project"/dns

terraform init
terraform apply

################################################
### Delete previous test config
################################################

kubectl config delete-context "$k8s_env"
kubectl config delete-user "$k8s_env"
kubectl config delete-cluster "$k8s_env"

################################################
### Create kubernetes config
################################################

mkdir -p ~/.kube
scp -o "StrictHostKeyChecking=accept-new" \
  -i "$ssh_priv_key" \
  cluster@"$master_ip_public":/etc/rancher/k3s/k3s.yaml \
  ~/.kube/config_"$k8s_env"

# Update endpoint
sed -i "s/127.0.0.1/$master_ip_public/g" ~/.kube/config_"$k8s_env"

# Update default names
sed -i "s/default/$k8s_env/g" ~/.kube/config_"$k8s_env"

# Export combination of kube configs
# kubectl should work already after this command, but the configuration is only in memory.
export KUBECONFIG=~/.kube/config:~/.kube/config_"$k8s_env"

# Merge all kubeconfig files
kubectl config view --flatten > ~/.kube/all-in-one-kubeconfig.yaml

# Create default config
cp ~/.kube/config ~/.kube/config.bak-$(date +"%Y-%m-%d_%H-%M_%S")
cp ~/.kube/all-in-one-kubeconfig.yaml ~/.kube/config

# Check that all clusters are listed
kubectl config get-clusters

# Change context to the new cluster
kubectl config use-context "$k8s_env"

# Check that nodes are available
kubectl get nodes

################################################
### Deploy Traefik
################################################

# Old instructiosn
#cd $HOME/scripts/tfcloud-operator2
#make deploy-traefik
#cd -

cd "$git_repo_full_path"/"$project_root_dir"/"$project"/traefik

TRAEFIK_NAMESPACE=traefik
TRAEFIK_VERSION=37.0.0
# CRD must match the Traefik version
TRAEFIK_CRD_VERSION=v3.5

helm repo add --force-update traefik https://traefik.github.io/charts
helm repo update
helm search repo traefik
  # NAME                    CHART VERSION   APP VERSION     DESCRIPTION
  # traefik/traefik         37.0.0          v3.5.0          A Traefik based Kubernetes ingress controller
  # traefik/traefik-crds    1.10.0                          A Traefik based Kubernetes ingress controller
  # traefik/traefik-hub     4.2.0           v2.11.0         Traefik Hub Ingress Controller
  # traefik/traefik-mesh    4.1.1           v1.4.8          Traefik Mesh - Simpler Service Mesh
  # traefik/traefikee       4.2.5           v2.12.5         Traefik Enterprise is a unified cloud-native ne...
  # traefik/maesh           2.1.2           v1.3.2          Maesh - Simpler Service Mesh

kubectl create namespace $TRAEFIK_NAMESPACE || echo "Namespace $TRAEFIK_NAMESPACE already exists"

kubectl -n $TRAEFIK_NAMESPACE apply -f https://raw.githubusercontent.com/traefik/traefik/"$TRAEFIK_CRD_VERSION"/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

kubectl -n $TRAEFIK_NAMESPACE apply -f https://raw.githubusercontent.com/traefik/traefik/"$TRAEFIK_CRD_VERSION"/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml

helm upgrade --install traefik traefik/traefik \
  --create-namespace --namespace $TRAEFIK_NAMESPACE \
  --values traefik-helm-values-v37.yaml \
  --version ${TRAEFIK_VERSION}

kubectl apply -f traefik-middleware-v37.yaml

# After couple minutes Load balancer target should show healthy at console.hetzner.cloud

################################################
### Install ArgoCD with Helm
################################################

cd "$git_repo_full_path"/"$project_root_dir"/"$project"/argocd

helm install \
    --values argocd_helm_values.yaml \
    argocd argo/argo-cd \
    -n argocd \
    --create-namespace

sed "s/example.com/$sub_domain_name.$tld_domain_name/g" argocd-ingress-traefik.yaml \
    | kubectl apply -f -

# Check the admin password with instructions given on shell
# https://argocd.<subdomain>.<tld> should work now

################################################
### Add ArgoCD app repo
################################################

argocd login argocd."$sub_domain_name"."$tld_domain_name"
argocd repo add "$argocd_app_repo_url_git" \
    --ssh-private-key-path "$argocd_priv_key" \
    --name "$argocd_app_repo_name"

# Create app via CLI
argocd app create "$argocd_app_demo_name" -f "$argocd_app_demo_yaml"

# Synchronize the app
argocd app sync "$argocd_app_demo_name"

# Set permissions for the privatebin folder
ssh -i "$ssh_priv_key" cluster@"$master_ip_public" "sudo chown www-data: /mnt/data/$argocd_app_demo_name && sudo chmod 775 /mnt/data/$argocd_app_demo_name"

# https://"$argocd_app_demo_name".<subdomain>.<tld> should work now

################################################
### Monitoring Prometheus
################################################

# Medium Post
# https://medium.com/@gayatripawar401/deploy-prometheus-and-grafana-on-kubernetes-using-helm-5aa9d4fbae66 

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus -n monitoring --create-namespace

# Expose Prometheus with ingress and basic auth
# Notice if deployemnt is in some other namespace than monitoring,
# one needs to edit "$prometheus_ingress_yaml" file
sed "s/example.com/$sub_domain_name.$tld_domain_name/g" "$prometheus_ingress_yaml" | kubectl -n monitoring apply -f -

# Docs https://prometheus.io/docs/guides/node-exporter/

# https://prometheus.<subdomain>.<tld> should work now

################################################
### Monitoring Grafana
################################################

helm repo add grafana https://grafana.github.io/helm-charts 
helm repo update
helm install grafana grafana/grafana -n monitoring

# Expose Prometheus with ingress
sed "s/example.com/$sub_domain_name.$tld_domain_name/g" "$grafana_ingress_yaml" | kubectl -n monitoring apply -f -

# Check the admin password with instructions given on shell
# https://grafana.<subdomain>.<tld> should work now

################################################
### Monitoring Grafana Datasources and Dashboards
################################################

# Store Grafana admin password in variable
grafana_admin_pw=$(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)

# Create data source: Prometheus
curl -X POST -k -H "Content-Type: application/json" -d "$(cat $grafana_ds_prometheus_json)" --location https://grafana.$sub_domain_name.$tld_domain_name/api/datasources --user "admin:$grafana_admin_pw"

# THIS DOES NOT WORK! ADD MANUALLY!
# Add dashboard
#curl -X POST -k -H "Content-Type: application/json" -d "{\"dashboard\":$(echo $grafana_dashboard_json)}" --location https://grafana.$sub_domain_name.$tld_domain_name/api/dashboards/import --user "admin:$grafana_admin_pw"

~~~

### Add Prometheus datasource and dashboard manually to Grafana

1. If Prometheus datasource was not added via CLI, add it.
    * Connections -> Datasource
    * Name: prometheus
    * Connection:
      * Prometheus server URL: <http://prometheus-server>
1. Add Prometheus as Dashboard in Grafana
    1. Check Prometheus Dashboard ID
        * <https://grafana.com/grafana/dashboards/315-kubernetes-cluster-monitoring-via-prometheus/>
        * ID = 315
    1. Dashboards -> New -> Import -> ID = 315
    1. Prometheus -> prometheus
    1. Dashboard should look something like
      ![Grafana / Prometheus demo](img/grafana_demo_hetzner.png)

### Destroy the infrastructure

Destroy is in reversed order to creation.

~~~sh
# Set this if you want auto approval destroy
auto_approve="--auto-approve"

# Destroy k3s
cd "$git_repo_full_path"/"$project_root_dir"/"$project"/k3s
terraform destroy "$auto_approve"

# Destroy admin SSH key
cd "$git_repo_full_path"/"$project_root_dir"/"$project"/ssh_keys
terraform destroy "$auto_approve"

# Destroy static IP of Kubernetes master
cd "$git_repo_full_path"/"$project_root_dir"/"$project"/ips
terraform destroy "$auto_approve"

# Destroy network
cd "$git_repo_full_path"/"$project_root_dir"/"$project"/networks
terraform destroy "$auto_approve"

# Destroy DNS
cd "$git_repo_full_path"/"$project_root_dir"/"$project"/dns
terraform destroy "$auto_approve"
~~~

## How the setup could be improved

These improvements are not in any specific order.

* Add vulnerability checks for deployed pods.
  * Open source software `syft`, `grype`, and/or `trivy` could be used.
  * [Docker Image Vulnerability Scan](../../security/vulnerability_scan_docker_Image.md)
* Storage of sensitive data
  * SOPS, Vault...
* Enhance monitoring/observability
  * Prometheus, Grafana...
* Shared storage options
  * [HetznerCloud/csi-driver](https://github.com/hetznercloud/csi-driver)
  * NFS
* Add a CICD pod / pipeline
  * GitHub Actions, GitLab, Jenkins...
* Add RBAC for developers
* Automate DNS record creation
  * Don't give full access to DNS domain management! Only certain records.
* Cost estimation
* Visualize infrastrucutre by generating an image
