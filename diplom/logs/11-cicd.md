### CI/CD пайплайн

```
$ kubectl get deployment diplom-app -n diplom -o jsonpath='{...image}'
cr.yandex/crp1oavjn6oftmsg31lk/diplom-app:v1.0.0

$ curl http://89.169.180.0/
    <h1>Дипломный практикум Yandex.Cloud</h1>
    <p>Ларин Владимир</p>
    <p>Дипломный практикум, 2026</p>
    <p class="ver">version: v1.0.0</p>

$ yc container image list
latest
commit-d544746
commit-78fac7d
v0.1.0
```
