# k8s Cheatsheet

<https://kubernetes.io/docs/reference/kubectl/cheatsheet/>

## Install kubectl

### WSL 2 Debian installation

~~~sh
cd /tmp
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
~~~

## Install kubectx and kubens

### WSL 2 Debian

~~~sh
cd /tmp
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
cd -
~~~

## Tab completion scripts for bash

~~~sh
sudo apt install pkg-config bash-completion

cd /tmp
git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
COMPDIR=$(pkg-config --variable=completionsdir bash-completion)
sudo ln -sf ~/.kubectx/completion/kubens.bash $COMPDIR/kubens
sudo ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx
cat << EOF >> ~/.bashrc

# kubectx and kubens
export PATH=~/.kubectx:\$PATH
alias kx=kubectx

# kubectl
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
EOF

cd -

source ~/.bashrc
~~~

## AWS EKS update kubeconfig

~~~sh
aws --profile k8s007 eks update-kubeconfig --name k8s007 --region eu-central-1
~~~

* Output

  ~~~sh
  Added new context arn:aws:eks:eu-central-1:123456789012:cluster/k8s007 to /home/iisti/.kube/config
  ~~~

## Use different Kubeconfig files

If one is constantly using different configuration files, one can easily set aliases for couple different files.

* This could be added into `~/.bashrc`, so the alias works even if shell is restarted.

    ~~~sh
    alias kaws="kubectl --kubeconfig ~/.kube/config_aws"
    ~~~

### Combine default k3s configurations

By default k3s kubeconfig looks something like below.
  
  ~~~yaml
  apiVersion: v1
  clusters:
  - cluster:
      certificate-authority-data: <LONG_CENSORED_DATA_STING>
      server: https://127.0.0.1:6443
    name: default
  contexts:
  - context:
      cluster: default
      user: default
    name: default
  current-context: default
  kind: Config
  preferences: {}
  users:
  - name: default
    user:
      client-certificate-data: <LONG_CENSORED_DATA_STING>
      client-key-data: <LONG_CENSORED_DATA_STING>
  ~~~

Combine multiple k3s configurations with these steps. These steps assume that k3s are deployed externally and have different cluster endpoints. If there would be three k3s configurations, they could be updated like this.

Files:

~~~sh
~/.kube/config_k3s_01
~/.kube/config_k3s_02
~/.kube/config_k3s_03
~~~

1. Update endpoints in each k3s file.

    ~~~sh
    # Set cluster endpoint IPs
    k3s_ip_01=123.123.123.121
    k3s_ip_02=123.123.123.122
    k3s_ip_03=123.123.123.123
  
    # Update cluster endpoint IPs in kubeconfig files
    sed -i "s/127.0.0.1/$k3s_ip_01/g" ~/.kube/config_k3s_01
    sed -i "s/127.0.0.1/$k3s_ip_02/g" ~/.kube/config_k3s_02
    sed -i "s/127.0.0.1/$k3s_ip_03/g" ~/.kube/config_k3s_03
  
    # Update default names
    sed -i 's/default/k3s-01/g' ~/.kube/config_k3s_01
    sed -i 's/default/k3s-02/g' ~/.kube/config_k3s_02
    sed -i 's/default/k3s-03/g' ~/.kube/config_k3s_03
    ~~~

2. Export combination of kubeconfigs

    ~~~sh
    export KUBECONFIG=~/.kube/config_k3s_01:~/.kube/config_k3s_02:~/.kube/config_k3s_03
    ~~~

3. Merge all kubeconfig files

    ~~~sh
    kubectl config view --flatten > ~/.kube/all-in-one-kubeconfig.yaml
    ~~~
  
    * One can combine all configs in a current folder if there are multiple files
  
        ~~~sh
        export KUBECONFIG=~/.kube/config:$(find . -type f | tr '\n' ':')
        ~~~

4. Create default kubeconfig
  
    ~~~sh
    cp ~/.kube/config ~/.kube/config.bak-$(date +"%Y-%m-%d_%H-%M_%S")
    cp ~/.kube/all-in-one-kubeconfig.yaml ~/.kube/config
    ~~~

5. Check that all clusters are listed
  
    ~~~sh
    kubectl config get-clusters
    ~~~

    * Output should be something like
  
        ~~~sh
        NAME
        k3s-01
        k3s-02
        k3s-03
        ~~~

## Tricks and tips

* Check kubelet config

    ~~~sh
    kubectl get --raw "/api/v1/nodes/<nodename>/proxy/configz" | jq
    ~~~

* Copy a file from pod to local
  * Notice, the pod has to have tar installed. It's normal that there's a message ``tar: Removing leading `/` from member names``
  
  ~~~sh
  kubectl cp namespace/podname:/path/target.txt /local_path/target.txt
  ~~~

## Logs: print pod logs with jq

When piping pod logs into jq, there can be an error similar to `parse error: Invalid numeric literal at line 2, column 5`. One can bypass the error with grep.

  ~~~sh
  kubectl -n mynamespace logs master-76b4998796-zlbwj | tee >(grep -v "^{") | grep "^{" | jq .
  ~~~

* Log output is like:

    ~~~sh
    {
      "iso8601Utc": "2024-09-25T06:57:03.816+0000",
      "level": "INFO",
      "loggerName": "org.apache.catalina.startup.Catalina",
      "message": "Server startup in [26516] milliseconds",
      "ndc": "",
      "module": "start"
    }
    ~~~

One can select certain messages by keys. In the below example prints all entries except log level INFO.

  ~~~sh
  kubectl -n mynamespace logs master-76b4998796-zlbwj | tee >(grep -v "^{") | grep "^{" | jq '. | select(.level!="INFO")'
  ~~~

## Memory usage

* Most of the scripts require jq and kubectl alias k

### Check how much memory one namespace is using

* Change the ns variable's value. Also if the memories are different unit than Mi (Mebibyte ~ Megabyte), this one-liner needs to be adjusted.

    ~~~sh
    ns="ns_name"; total=0; while read i; do (( total+="$i" )); done <<< "$(k top pods -n "$ns" --sort-by='memory' | tail -n +2 | tr -s " " | cut -d" " -f3 | tr -d "Mi")"; echo "$total"
    ~~~

### Check memory usage of all PODs in all namespaces

~~~sh
while read ns; do echo "Namespace: $ns" && k -n $ns top po ; done <<< "$(k get namespaces -o json | jq -r '.items[].metadata.name')"
~~~

### Check how much memory all namespaces are using

* Writes output into file `"$stage"ns_mem_usage_$(date +"%Y-%m-%d_%H-%M").txt`

    ~~~sh
    readarray -t arr_namespaces <<< "$(k get namespaces -o json | jq -r '.items[].metadata.name')"
    datefile=$(date +"%Y-%m-%d_%H-%M")
    stage=""
    
    for ns in "${arr_namespaces[@]}"
    do
        # Check if there are resources in the namespace
        no_resources=$(k -n "$ns" get po 2>&1)
        if [ "$no_resources" = "No resources found in $ns namespace." ]
        then
            continue
        fi
        
        total=0
        while read i
        do
            (( total+="$i" ))
        done <<< "$(k top pods --use-protocol-buffers -n "$ns" --sort-by='memory' | \
            tail -n +2 | \
            tr -s " " | \
            cut -d" " -f3 | \
            tr -d "Mi")"
    
        echo "$ns: $total Mi" >> "$stage"ns_mem_usage_"$datefile".txt
    done
    
    cat "$stage"ns_mem_usage_"$datefile".txt
    
    cp "$stage"ns_mem_usage_"$datefile".txt "$stage"ns_mem_usage_"$datefile".txt.tmp
    echo "" >> "$stage"ns_mem_usage_"$datefile".txt
    echo "Total memory usage of namespaces:" >> "$stage"ns_mem_usage_"$datefile".txt
    file=""$stage"ns_mem_usage_"$datefile".txt.tmp"; total=0; while read i; do (( total+="$i" )); done <<< "$(cat $file | cut -d' ' -f2)"; awk -v total="$total" 'BEGIN{print total " Mi"}' >> "$stage"ns_mem_usage_"$datefile".txt
    
    rm "$stage"ns_mem_usage_"$datefile".txt.tmp
    ~~~

## Check Node POD capacity and non-terminated PODs

There are different POD capacity limits for different instance types, e.g. m6a.xlarge supports 58 PODs

* <https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt>
* <https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html>
  * *AWS Nitro System instance types optionally support significantly more IP addresses than non-Nitro System instance types. However, not all IP addresses assigned for an instance are available to Pods. To assign a significantly larger number of IP addresses to your instances, you must have version 1.9.0 or later of the Amazon VPC CNI add-on installed in your cluster and configured appropriately.*
* [Amazon VPC CNI plugin increases pods per node limits](https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/)

* Shell script

    ~~~sh
    while read node; do echo "Node: $node"; k describe node "$node" | grep 'Non-terminated Pods:'; printf "Capacity pods: "; k get nodes -l kubernetes.io/hostname="$node" -ojson  | jq -r '.items[].status.capacity.pods'  ; done <<< "$(k get nodes -ojson | jq -r '.items[].metadata.labels."kubernetes.io/hostname"')"
    ~~~

  * Output

    ~~~sh
    Node: ip-10-1-2-94.eu-central-1.compute.internal
    Non-terminated Pods:          (53 in total)
    Capacity pods: 58
    Node: ip-10-1-3-12.eu-central-1.compute.internal
    Non-terminated Pods:          (58 in total)
    Capacity pods: 58
    ~~~

## Add a single hostname to CoreDNS' Corefile

Add a single hostname to CoreDNS' Corefile, so the Kubernetes resources can resolve the hostname.

~~~sh
kubectl -n kube-system get cm coredns -o yaml > coredns_backup_$(date +"%Y-%m-%d_%H-%M_%S").yaml
kubectl -n kube-system edit cm coredns
~~~

Add line `111.111.222.222 host.example.com` into hosts block. After configuration restart CoreDNS pod. The below configuration file is from k3s installation.

~~~yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
        }
        hosts /etc/coredns/NodeHosts {
          111.111.222.222 host.example.com # add this line
          ttl 60
          reload 15s
          fallthrough
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
        import /etc/coredns/custom/*.override
    }
    import /etc/coredns/custom/*.server
  NodeHosts: |
    123.123.123.123 master-node
kind: ConfigMap
metadata:
  annotations:
    objectset.rio.cattle.io/applied: XXXX
    objectset.rio.cattle.io/id: ""
    objectset.rio.cattle.io/owner-gvk: k3s.cattle.io/v1, Kind=Addon
    objectset.rio.cattle.io/owner-name: coredns
    objectset.rio.cattle.io/owner-namespace: kube-system
  creationTimestamp: "2024-10-22T11:39:28Z"
  labels:
    objectset.rio.cattle.io/hash: bce283298811743a0386ab510f2f67ef74240c57
  name: coredns
  namespace: kube-system
  resourceVersion: "7965664"
  uid: 5bbf0de9-de40-42a3-a27c-82b494a3526d
~~~

## Check VictoriaMetrics

* Check PODs

    ~~~sh
    k -n monitoring get po
    NAME                                                              READY   STATUS    RESTARTS   AGE
    blackbox-exporter-prometheus-blackbox-exporter-xxxxxxxxxx-yyyyy   1/1     Running   0          68d
    postgres-exporter-prometheus-postgres-exporter-xxxxxxxxxx-yyyyy   1/1     Running   0          82d
    vika-grafana-xxxxxxxxxx-yyyyy                                     3/3     Running   0          66d
    vika-kube-state-metrics-xxxxxxxxx-yyyyy                           1/1     Running   0          68d
    vika-prometheus-node-exporter-yyy01                               1/1     Running   0          88d
    vika-prometheus-node-exporter-yyy02                               1/1     Running   0          88d
    vika-prometheus-node-exporter-yyy03                               1/1     Running   0          88d
    vika-prometheus-node-exporter-yyy04                               1/1     Running   0          68d
    vika-prometheus-node-exporter-yyy05                               1/1     Running   0          88d
    vika-victoria-metrics-operator-xxxxxxxxx-yyyyy                    1/1     Running   1          68d
    vmagent-vika-victoria-metrics-k8s-stack-xxxxxxxxxx-yyyyy          2/2     Running   0          68d
    vmalert-vika-victoria-metrics-k8s-stack-xxxxxxxxxx-yyyyy          2/2     Running   0          68d
    vmalertmanager-vika-victoria-metrics-k8s-stack-0                  2/2     Running   0          68d
    vminsert-vika-victoria-metrics-k8s-stack-xxxxxxxxxx-yyyyy         1/1     Running   0          68d
    vmselect-vika-victoria-metrics-k8s-stack-0                        1/1     Running   0          81d
    vmstorage-vika-victoria-metrics-k8s-stack-0                       1/1     Running   1          81d
    yace-yet-another-cloudwatch-exporter-xxxxxxxxxx-yyyyy             1/1     Running   0          68d
    ~~~

* Start port-forward

    ~~~sh
    k -n monitoring port-forward vmselect-vika-victoria-metrics-k8s-stack-0 8481:8481
    ~~~

* Now the Web UI for VictoriaMetrics works works

    ~~~sh
    http://localhost:8481/select/0/vmui
    ~~~

## ArgoCD

* Port-forward ArgoCD server. Afterwards ArgoCD is available at <http://localhost:8080>

    ~~~sh
    kubectl port-forward service/argocd-server -n argocd 8080:443
    ~~~

* Default admininistrator user is admin and the initial password can be extracted with command below.

    ~~~sh
    k -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ~~~

## Databases

### Run mysql-client on Kubernetes for testing purposes

~~~sh
kubectl run mysql-client --image=mysql:9.0.1 -it --rm --restart=Never -- /bin/bash

If you don't see a command prompt, try pressing enter.
bash-5.1#
~~~
