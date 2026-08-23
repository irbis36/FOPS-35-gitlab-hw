### Система мониторинга

```
$ kubectl get pods -n monitoring
NAME                                                     READY   STATUS    RESTARTS      AGE
alertmanager-monitoring-kube-prometheus-alertmanager-0   2/2     Running   2 (33m ago)   6d23h
monitoring-grafana-557c859c49-5w4kg                      3/3     Running   4 (33m ago)   6d23h
monitoring-kube-prometheus-operator-854d4fbdfc-fcwjp     1/1     Running   1 (33m ago)   6d23h
monitoring-kube-state-metrics-5c888c46d7-9wcnn           1/1     Running   1 (33m ago)   6d23h
monitoring-prometheus-node-exporter-2mz4d                1/1     Running   1 (33m ago)   6d23h
monitoring-prometheus-node-exporter-6vtl7                1/1     Running   1 (33m ago)   6d23h
monitoring-prometheus-node-exporter-phkpt                1/1     Running   1 (33m ago)   6d23h
prometheus-monitoring-kube-prometheus-prometheus-0       2/2     Running   2 (33m ago)   6d23h

$ kubectl get ingress -A
NAMESPACE    NAME                 CLASS   HOSTS                         ADDRESS                PORTS   AGE
diplom       diplom-app           nginx   *                             10.10.2.8,10.10.3.19   80      6d23h
monitoring   monitoring-grafana   nginx   grafana.89.169.180.0.nip.io   10.10.2.8,10.10.3.19   80      6d23h
```
