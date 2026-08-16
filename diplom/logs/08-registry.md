### Публикация образа в Container Registry

```
$ docker login --username json_key --password-stdin cr.yandex < ci-sa-key.json
Login Succeeded

$ docker push cr.yandex/crp1oavjn6oftmsg31lk/diplom-app:v0.1.0
v0.1.0: digest: sha256:cbba618a4cd71a1b60c12c9f50e635f6584f2142d86fbb9632972d82ad908ac7 size: 856

$ yc container image list --registry-id crp1oavjn6oftmsg31lk
crp1oavjn6oftmsg31lk/diplom-app:v0.1.0
crp1oavjn6oftmsg31lk/diplom-app:sha256:12a51ee1d13e850f1616485f74b77961d5760e9334d160012dd432c44aca0eda
crp1oavjn6oftmsg31lk/diplom-app:sha256:bfcc40077e835e72f70363146a673ed3c90ddafea65860531eecd95748606e63
```
