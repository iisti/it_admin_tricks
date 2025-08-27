#!/usr/bin/env bash

func_get_master_ip_public () {
    # cd into terraform directory
    cd "$git_repo_full_path"/"$project_root_dir"/"$project"/k3s

    # Get k3s master IP
    master_ip_public=$(terraform show -json | 
        jq -r '.values.outputs.vms.value[] | 
        select(.vm_name | 
        startswith("master")) | 
        .vm_ip_public')
    
    echo "$master_ip_public"
}

func_get_lb_ip_public () {
    # cd into terraform directory
    cd "$git_repo_full_path"/"$project_root_dir"/"$project"/k3s

    # Get LB IP
    lb_ip_public=$(terraform show -json | jq -r .values.outputs.lb_ips.value[])
    echo "$lb_ip_public"
}

if test -f "$1"; then
    source $1
else
    echo "ERROR: No proper argument was given!"
    exit 1
fi

master_ip_public=$(func_get_master_ip_public)
lb_ip_public=$(func_get_lb_ip_public)

cd "$git_repo_full_path"/"$project_root_dir"/"$project"

sed -i "s|VAR_MASTER_PUBLIC_IP|$master_ip_public|g" \
    dns/dns_records.yaml \
    "$1"

sed -i "s|VAR_LB_PUBLIC_IP|$lb_ip_public|g" \
    dns/dns_records.yaml \
    "$1"

### Check if all variables have been substituted.
grep_var=$(grep -r --exclude=sed-env* --exclude=sed-dns* "VAR_")

if [ ! -z "$grep_var" ]; then
    echo "ERROR: All variables VAR_VARIABLE_NAME have not been substituted! Check the following."
    echo "$grep_var"
fi