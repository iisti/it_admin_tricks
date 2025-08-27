#!/usr/bin/env bash

### NOTICE 
# VAR_GCS_PREFIX_NETWORKS is in both networks and k3s main.tf
# VAR_NETWORK_NAME is in both networks and k3s variables.tf
# VAR_VM_NAME_MASTER is in:
#   ips and k3s variables.tf
#   dns dns_records.yaml
# VAR_VM_LABEL_MASTER is in:
#   ips and k3s variables.tf
# VAR_TLD_DOMAIN_NAME and VAR_SUB_DOMAIN_NAME are in:
#   k3s variables.tf
#   dns dns_records.yaml

# Use | as sed delimiter

# Check if 1st argument is empty. There should be either configuration file or "dns" as an option.
# If arg is "dns", then set IPs to the dns_records.yaml
# elif source arg if the file exists
if [ "$1" = "dns" ]; then
    echo "dns chosen"
    exit 0
elif test -f "$1"; then
    source $1
else
    echo "ERROR: No proper argument was given!"
    exit 1
fi

### sed global variables
sed -i "s|VAR_TF_VERSION|$terraform_version|g" \
    dns/main.tf \
    ips/main.tf \
    k3s/main.tf \
    networks/main.tf \
    ssh_keys/main.tf 
sed -i "s|VAR_HCLOUD_VERSION|$hcloud_version|g" \
    ips/main.tf \
    k3s/main.tf \
    networks/main.tf \
    ssh_keys/main.tf 
sed -i "s|VAR_GCS_BUCKET|$gcs_bucket|g" \
    dns/main.tf \
    ips/main.tf \
    k3s/main.tf \
    networks/main.tf \
    ssh_keys/main.tf 
sed -i "s|VAR_SSH_KEY_NAME_ADMIN|$ssh_key_name_admin|g" \
    ssh_keys/variables.tf \
    k3s/terraform.tfvars
sed -i "s|VAR_SSH_KEY_PUBLIC_ADMIN|$ssh_key_public_admin|g" \
    ssh_keys/variables.tf \
    k3s/terraform.tfvars
sed -i "s|VAR_HCLOUD_TOKEN|$hcloud_token|g" \
    ips/terraform.tfvars \
    ssh_keys/terraform.tfvars \
    k3s/terraform.tfvars \
    networks/terraform.tfvars
sed -i "s|VAR_PROJECT|$project|g" \
    ips/terraform.tfvars \
    ssh_keys/terraform.tfvars \
    k3s/variables.tf \
    k3s/terraform.tfvars \
    networks/terraform.tfvars

#### sed dns
sed -i "s|VAR_GERMANBREW_HETZNERDNS_VERSION|$germanbrew_hetznerdns_version|g" \
    dns/main.tf
sed -i "s|VAR_GCS_PREFIX_DNS|$gcs_prefix_dns|g" \
    dns/main.tf
sed -i "s|VAR_DNS_API_TOKEN|$dns_api_token|g" \
    dns/terraform.tfvars
sed -i "s|VAR_LB_NAME|$dns_lb_name|g" \
    dns/dns_records.yaml
    
#### sed ips
sed -i "s|VAR_VM_NAME_MASTER|$vm_name_master|g" \
    ips/variables.tf \
    k3s/variables.tf
sed -i "s|VAR_VM_LABEL_MASTER|$vm_labels_master|g" \
    ips/variables.tf \
    k3s/variables.tf
sed -i "s|VAR_IP_DATACENTER|$ip_datacenter|g" \
    ips/variables.tf
sed -i "s|VAR_GCS_PREFIX_IPS|$gcs_prefix_ips|g" \
    ips/main.tf

### sed k3s main and terraform.tfvars
sed -i "s|VAR_GCS_PREFIX_K3S|$gcs_prefix_k3s|g" \
    k3s/main.tf
sed -i "s|VAR_FW_LABEL_MASTER|$firewall_label_master|g" \
    k3s/main.tf
sed -i "s|VAR_SSH_KEY_PUBLIC_WORKER|$ssh_key_pub_worker|g" \
    k3s/terraform.tfvars
# SSH Key requires special handling because we're adding multiline variable.
# 1st append variable after VAR_SSH_KEY_PRIVATE_WORKER
# 2nd remove VAR_SSH_KEY_PRIVATE_WORKER
sed -i '/VAR_SSH_KEY_PRIVATE_WORKER/r /dev/stdin' <<< "$ssh_key_worker_private" \
    k3s/terraform.tfvars
sed -i '/VAR_SSH_KEY_PRIVATE_WORKER/d' \
    k3s/terraform.tfvars


### sed k3s variables.tf
sed -i "s|VAR_TLD_DOMAIN_NAME|$tld_domain_name|g" \
    k3s/variables.tf \
    dns/dns_records.yaml
sed -i "s|VAR_SUB_DOMAIN_NAME|$sub_domain_name|g" \
    k3s/variables.tf \
    dns/dns_records.yaml

#### master config
sed -i "s|VAR_MASTER_IP_INTERNAL|$master_ip_internal|g" \
    k3s/variables.tf
sed -i "s|VAR_VM_NAME_MASTER|$vm_name_master|g" \
    k3s/variables.tf \
    dns/dns_records.yaml

sed -i "s|VAR_BASE_NAME|$base_name|g" \
    k3s/variables.tf
sed -i "s|VAR_VM_IMAGE|$vm_image|g" \
    k3s/variables.tf
sed -i "s|VAR_VM_TYPE|$vm_type|g" \
    k3s/variables.tf
sed -i "s|VAR_VM_DATACENTER|$vm_datacenter|g" \
    k3s/variables.tf
sed -i "s|VAR_VM_BACKUPS|$vm_backups|g" \
    k3s/variables.tf
sed -i "s|VAR_VM_DELETE_PROTECTION|$vm_delete_protection|g" \
    k3s/variables.tf
sed -i "s|VAR_VM_REBUILD_PROTECTION|$vm_rebuild_protection|g" \
    k3s/variables.tf
sed -i "s|VAR_SSH_KEY_LABEL|$ssh_key_label|g" \
    k3s/variables.tf
sed -i "s|VAR_NETWORK_NAME|$network_name|g" \
    k3s/variables.tf
sed -i "s|VAR_MASTER_IP_INTERNAL|$private_ip|g" \
    k3s/variables.tf
sed -i "s|VAR_PUBLIC_IP_LABEL_MASTER|$public_ip_label|g" \
    k3s/variables.tf
sed -i "s|VAR_USER_DATA_FILE_MASTER|$user_data_file|g" \
    k3s/variables.tf
sed -i "s|VAR_DATABASE_CERTIFICATE_EMAIL|$database_certificate_email|g" \
    k3s/variables.tf
sed -i "s|VAR_DELETE_PROTECTION_MASTER|$delete_protection|g" \
    k3s/variables.tf
sed -i "s|VAR_AUTO_DELETE_MASTER|$auto_delete|g" \
    k3s/variables.tf


# IP ingresses special handling because we're adding a multiline variable.
# 1st append multiline variable
# 2nd remove remove the place holder VAR_SOMETHING
sed -i '/VAR_IPS_SSH_INGRESS/r /dev/stdin' <<< "$ips_ssh_ingress" \
    k3s/variables.tf
sed -i '/VAR_IPS_SSH_INGRESS/d' \
    k3s/variables.tf
sed -i '/VAR_IPS_KUBERNETES_API_INGRESS/r /dev/stdin' <<< "$ips_kubernetes_api_ingress" \
    k3s/variables.tf
sed -i '/VAR_IPS_KUBERNETES_API_INGRESS/d' \
    k3s/variables.tf


### sed networks
sed -i "s|VAR_GCS_PREFIX_NETWORKS|$gcs_prefix_networks|g" \
    networks/main.tf \
    k3s/main.tf
sed -i "s|VAR_NETWORK_NAME|$network_name|g" \
    networks/variables.tf \
    k3s/variables.tf
sed -i "s|VAR_NETWORK_IP_RANGE|$network_ip_range|g" \
    networks/variables.tf
sed -i "s|VAR_SUBNET_IP_RANGE|$subnet_ip_range|g" \
    networks/variables.tf

### sed ssh_keys
sed -i "s|VAR_GCS_PREFIX_SSH_KEYS|$gcs_prefix_ssh_keys|g" \
    ssh_keys/main.tf

### Check if all variables have been substituted.
grep_var=$(grep -r --exclude=sed-env* --exclude=sed-dns* --exclude=*.tf-env "VAR_")

# Exclude IP variables
grep_var=$(echo "$grep_var" | grep -Ev 'VAR_MASTER_PUBLIC_IP|VAR_LB_PUBLIC_IP')

if [ ! -z "$grep_var" ]; then
    echo "ERROR: All variables VAR_VARIABLE_NAME have not been substituted! Check the following."
    echo "$grep_var"
fi