### Деплой приложения в кластер

```
$ kubectl get pods,svc,ingress -n diplom
NAME                              READY   STATUS    RESTARTS   AGE
pod/diplom-app-84798df5f7-ccblt   1/1     Running   0          84s
pod/diplom-app-84798df5f7-s2vsf   1/1     Running   0          84s

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/diplom-app   ClusterIP   10.233.2.79   <none>        80/TCP    84s

NAME                                   CLASS   HOSTS   ADDRESS                PORTS   AGE
ingress.networking.k8s.io/diplom-app   nginx   *       10.10.2.8,10.10.3.19   80      83s

$ curl http://89.169.180.0/
    <p>Ларин Владимир</p>
    <p class="ver">version: v0.1.0</p>
```
