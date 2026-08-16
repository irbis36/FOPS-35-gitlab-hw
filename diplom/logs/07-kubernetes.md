### Kubernetes кластер

```
$ ansible-playbook cluster.yml  (фрагмент итога)
PLAY RECAP *********************************************************************
master                     : ok=708  changed=156  unreachable=0    failed=0    skipped=1092 rescued=0    ignored=6   
worker-1                   : ok=467  changed=93   unreachable=0    failed=0    skipped=695  rescued=0    ignored=1   
worker-2                   : ok=467  changed=93   unreachable=0    failed=0    skipped=692  rescued=0    ignored=1   

Monday 17 August 2026  01:28:50 +0500 (0:00:00.112)       0:18:24.343 ********* 

$ kubectl get nodes -o wide
NAME       STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
master     Ready    control-plane   6m29s   v1.31.9   10.10.1.12    <none>        Ubuntu 22.04.5 LTS   5.15.0-186-generic   containerd://1.7.27
worker-1   Ready    <none>          5m45s   v1.31.9   10.10.2.8     <none>        Ubuntu 22.04.5 LTS   5.15.0-186-generic   containerd://1.7.27
worker-2   Ready    <none>          5m46s   v1.31.9   10.10.3.19    <none>        Ubuntu 22.04.5 LTS   5.15.0-186-generic   containerd://1.7.27

$ kubectl get pods --all-namespaces
NAMESPACE       NAME                                       READY   STATUS    RESTARTS   AGE
ingress-nginx   ingress-nginx-controller-28n9l             1/1     Running   0          4m8s
ingress-nginx   ingress-nginx-controller-lv5n2             1/1     Running   0          4m8s
kube-system     calico-kube-controllers-7899b68c68-t8ngz   1/1     Running   0          4m25s
kube-system     calico-node-jwvqz                          1/1     Running   0          5m
kube-system     calico-node-sxp2p                          1/1     Running   0          5m
kube-system     calico-node-zrfhw                          1/1     Running   0          5m
kube-system     coredns-d665d669-d4bcb                     1/1     Running   0          4m3s
kube-system     coredns-d665d669-p9p8j                     1/1     Running   0          4m
kube-system     dns-autoscaler-5cb4578f5f-kkkhd            1/1     Running   0          4m1s
kube-system     kube-apiserver-master                      1/1     Running   1          6m27s
kube-system     kube-controller-manager-master             1/1     Running   2          6m27s
kube-system     kube-proxy-h26z9                           1/1     Running   0          5m41s
kube-system     kube-proxy-njwwx                           1/1     Running   0          5m41s
kube-system     kube-proxy-nskjn                           1/1     Running   0          5m41s
kube-system     kube-scheduler-master                      1/1     Running   1          6m21s
kube-system     metrics-server-6c8bff4c-rhbxb              1/1     Running   0          3m29s
kube-system     nginx-proxy-worker-1                       1/1     Running   0          5m43s
kube-system     nginx-proxy-worker-2                       1/1     Running   0          5m41s
kube-system     nodelocaldns-87xsb                         1/1     Running   0          3m58s
kube-system     nodelocaldns-cbkjs                         1/1     Running   0          3m58s
kube-system     nodelocaldns-mpmdj                         1/1     Running   0          3m58s
```
