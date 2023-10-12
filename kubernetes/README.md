# k8s Cheatsheet

https://kubernetes.io/docs/reference/kubectl/cheatsheet/

## Tricks and tips

* Check kubelet config
    ~~~
    kubectl get --raw "/api/v1/nodes/<nodename>/proxy/configz" | jq
    ~~~

### # Check VictoriaMetrics
* Check PODs
    ~~~
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
    ~~~
    k -n monitoring port-forward vmselect-vika-victoria-metrics-k8s-stack-0 8481:8481
    ~~~
    
* Now the Web UI for VictoriaMetrics works works
    ~~~
    http://localhost:8481/select/0/vmui
    ~~~
