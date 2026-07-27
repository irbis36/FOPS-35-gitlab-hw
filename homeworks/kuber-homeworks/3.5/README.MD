# Домашнее задание к занятию «Troubleshooting»

## Автор: Ларин Владимир

---

## Задание

При деплое приложение `web-consumer` не может подключиться к `auth-db`. Нужно найти и устранить проблему.

---

## 1. Установка приложения

Сначала создал неймспейсы `web` и `data`, потому что без них манифест не применялся — ругался на `namespaces not found`. После этого применил yaml-файл, всё создалось нормально.

```bash
microk8s kubectl create namespace web
microk8s kubectl create namespace data
microk8s kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
```

Исходный манифест: [task-original.yaml](task-original.yaml)

![Создание ресурсов](screenshot/screenshot_1.png)

## 2. Выявление проблемы

Проверил состояние подов в обоих неймспейсах:

```bash
microk8s kubectl get pods -n web
microk8s kubectl get pods -n data
```

![Состояние подов](screenshot/screenshot_2.png)

Поды `web-consumer` в статусе `ErrImagePull`. Посмотрел events через `describe`:

```bash
microk8s kubectl describe pod -n web web-consumer-6c5f7cc594-wblt4 | grep -A5 "Events"
```

![Ошибка при pull образа](screenshot/screenshot_3.png)

Также посмотрел, что внутри деплоймента — какой образ и какая команда:

```bash
microk8s kubectl get deployment web-consumer -n web -o yaml | grep -A20 "spec:"
```

![Спецификация деплоймента](screenshot/screenshot_4.png)

### Обнаруженные проблемы

Нашлось две ошибки:

1. **Образ `radial/busyboxplus:curl` не скачивается.** В describe видно сообщение `schema 1 image manifests are no longer supported`. Этот образ устарел и больше не поддерживается Docker Hub.

2. **Неправильный адрес сервиса в команде curl.** В деплойменте написано просто `curl auth-db`, но сервис `auth-db` находится в неймспейсе `data`, а под `web-consumer` — в неймспейсе `web`. Чтобы обращаться к сервису из другого неймспейса, нужно использовать полное DNS-имя: `auth-db.data.svc.cluster.local`.

## 3. Исправление проблемы

Заменил образ на рабочий `curlimages/curl:7.85.0` и поправил адрес сервиса:

```bash
microk8s kubectl set image deployment/web-consumer -n web busybox=curlimages/curl:7.85.0
microk8s kubectl patch deployment web-consumer -n web --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/command","value":["sh","-c","while true; do curl auth-db.data.svc.cluster.local; sleep 5; done"]}]'
```

![Исправление деплоймента](screenshot/screenshot_5.png)

Исправленный манифест: [task-fixed.yaml](task-fixed.yaml)

## 4. Проверка результата

После патча поды пересоздались и перешли в статус `Running`:

```bash
microk8s kubectl get pods -n web
```

![Поды запущены](screenshot/screenshot_6.png)

Проверил логи — `web-consumer` получает ответ от nginx (это и есть `auth-db`):

```bash
microk8s kubectl logs -n web deployment/web-consumer --tail=10
```

![Логи — ответ от auth-db](screenshot/screenshot_7.png)

Видно стандартную страницу nginx — значит `web-consumer` успешно подключается к `auth-db`. Проблема решена.

