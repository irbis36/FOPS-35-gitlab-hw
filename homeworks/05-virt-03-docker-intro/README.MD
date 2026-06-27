# Домашнее задание к занятию 4 «Оркестрация группой Docker контейнеров на примере Docker Compose»

**Автор: Ларин Владимир**

---

## Задача 1 — Установка Docker, сборка и публикация образа

### Проверка версий Docker и Docker Compose

```bash
root@vm1:/home/larin# docker --version && docker compose version
Docker version 29.6.0, build fb59821
Docker Compose version v5.2.0
```

### Скачивание образа nginx:1.29.0

```bash
root@vm1:/home/larin# docker pull nginx:1.29.0
1.29.0: Pulling from library/nginx
856c000ad0ec: Pull complete
b1badc6e5066: Pull complete
c5ada5e7d698: Pull complete
9dbfe0b105c9: Pull complete
dea1652b095a: Pull complete
85003794a6a5: Pull complete
fea7cebc499c: Pull complete
946b359b3ef2: Download complete
23dc44e5f024: Download complete
Digest: sha256:3ab4ed065a1437cbbd45e65617b1285bdf6523c6bf56a121e00df41720e09a89
Status: Downloaded newer image for nginx:1.29.0
docker.io/library/nginx:1.29.0
```

### Dockerfile

```dockerfile
FROM nginx:1.29.0
COPY index.html /usr/share/nginx/html/index.html
```

### index.html

```html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
```

### Сборка образа

```bash
root@vm1:~/custom-nginx# docker build -t custom-nginx:1.0.0 .
[+] Building 1.2s (7/7) FINISHED                                docker:default
 => [internal] load build definition from Dockerfile             0.1s
 => [2/2] COPY index.html /usr/share/nginx/html/index.html      0.1s
 => => naming to docker.io/library/custom-nginx:1.0.0            0.0s
```

### Публикация образа на DockerHub

```bash
root@vm1:~/custom-nginx# docker tag custom-nginx:1.0.0 irbis36/custom-nginx:1.0.0
root@vm1:~/custom-nginx# docker push irbis36/custom-nginx:1.0.0
The push refers to repository [docker.io/irbis36/custom-nginx]
...
1.0.0: digest: sha256:2370c89d03dd86f8c0cbe985e751210d22d0012a344be636a37728fd87b1b6e9 size: 856
```

**Ссылка на репозиторий:** https://hub.docker.com/r/irbis36/custom-nginx/general

---

## Задача 2 — Запуск и проверка контейнера

### Запуск контейнера и переименование

```bash
docker run -d --name "Larin-Vladimir-custom-nginx-t2" -p 127.0.0.1:8080:80 custom-nginx:1.0.0
docker rename "Larin-Vladimir-custom-nginx-t2" "custom-nginx-t2"
```

### Комплексная проверка (скриншот)

```bash
date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080 ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html
```

![Комплексная проверка контейнера](/screenshots/Screenshot_1.png)

### Проверка через curl (скриншот)

```bash
curl http://127.0.0.1:8080
```

![curl проверка доступности страницы](/screenshots/Screenshot_2.png)

---

## Задача 3 — Работа с потоками и конфигурацией контейнера

### Подключение к потокам контейнера и нажатие Ctrl-C (скриншот)

```bash
docker attach custom-nginx-t2
# нажата комбинация Ctrl-C
```

![docker attach и остановка контейнера через Ctrl-C](/screenshots/Screenshot_3.png)

### Проверка статуса контейнера — docker ps -a (скриншот)

```bash
docker ps -a
```

![docker ps -a — контейнер остановлен](/screenshots/Screenshot_4.png)

**Объяснение:** Команда `docker attach` подключает терминал напрямую к главному процессу контейнера (PID 1 — nginx). Нажатие Ctrl-C отправило сигнал **SIGINT** (сигнал 2) в этот процесс. Nginx корректно обработал сигнал и завершил работу. Поскольку главный процесс контейнера завершился — остановился и сам контейнер.

### Перезапуск контейнера и вход в bash (скриншот)

```bash
docker start custom-nginx-t2
docker exec -it custom-nginx-t2 bash
```

![Перезапуск контейнера и вход в bash](/screenshots/Screenshot_5.png)

### Проверка наличия nano (скриншот)

```bash
nano --version
```

![nano --version](/screenshots/Screenshot_6.png)

### Редактирование конфига nginx — замена порта 80 на 81 (скриншот)

```bash
nano /etc/nginx/conf.d/default.conf
cat /etc/nginx/conf.d/default.conf
```

![Конфиг nginx с портом 81](/screenshots/Screenshot_7.png)

### Перезагрузка nginx и проверка curl внутри контейнера (скриншот)

```bash
nginx -s reload ; curl http://127.0.0.1:80 ; curl http://127.0.0.1:81
```

![nginx reload и curl внутри контейнера](/screenshots/Screenshot_8.png)

### Проверка снаружи контейнера после изменения порта (скриншот)

```bash
ss -tlpn | grep 127.0.0.1:8080 ; docker port custom-nginx-t2 ; curl http://127.0.0.1:8080
```

![Проблема с портом снаружи контейнера](/screenshots/Screenshot_9.png)

**Объяснение проблемы:** Docker пробрасывает порт хоста **8080** на порт контейнера **80** (задано при запуске `-p 127.0.0.1:8080:80`). После изменения конфига nginx внутри контейнера стал слушать порт **81** вместо **80**. В результате цепочка разорвана: `хост:8080 → контейнер:80` — но на порту 80 внутри контейнера уже никто не слушает. Маппинг портов задаётся при запуске контейнера и не может быть изменён без его пересоздания.

### Удаление контейнера без остановки (скриншот)

```bash
docker rm -f custom-nginx-t2
```

![docker rm -f custom-nginx-t2](/screenshots/Screenshot_10.png)

---

## Задача 4 — Общий том между контейнерами

### Запуск контейнера CentOS с монтированием тома (скриншот)

```bash
docker run -d -v $(pwd):/data --name centos-container centos:7 tail -f /dev/null
```

![Запуск centos-container](/screenshots/Screenshot_11.png)

### Запуск контейнера Debian с монтированием тома (скриншот)

```bash
docker run -d -v $(pwd):/data --name debian-container debian:latest tail -f /dev/null
```

![Запуск debian-container](/screenshots/Screenshot_12.png)

### Создание файлов из CentOS-контейнера и с хоста (скриншот)

```bash
docker exec -it centos-container bash -c "echo 'Hello from CentOS container' > /data/centos-file.txt"
echo "Hello from host machine" > $(pwd)/host-file.txt && ls -la $(pwd)
```

![Создание файлов из centos-container и с хоста](/screenshots/Screenshot_13.png)

### Проверка файлов из Debian-контейнера (скриншот)

```bash
docker exec -it debian-container bash -c "ls -la /data && echo '---' && cat /data/centos-file.txt && cat /data/host-file.txt"
```

![Просмотр файлов из debian-container](/screenshots/Screenshot_14.png)

Все файлы, созданные как из контейнера CentOS, так и с хостовой машины, видны из контейнера Debian через общий том.

---

## Задача 5 — Docker Compose, Registry и Portainer

### Первый запуск docker compose up -d (скриншот)

```bash
docker compose up -d
```

![Первый docker compose up -d — запущен только portainer](/screenshots/Screenshot_15.png)

**Объяснение:** Был запущен файл `compose.yaml`, а не `docker-compose.yaml`. Согласно документации Docker Compose, при наличии нескольких файлов с поддерживаемыми именами приоритет отдаётся `compose.yaml` как основному имени файла. `docker-compose.yaml` является устаревшим вариантом и имеет более низкий приоритет.

### Редактирование compose.yaml — добавление директивы include (скриншот)

```yaml
version: "3"
services:
  portainer:
    network_mode: host
    image: portainer/portainer-ce:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

include:
  - docker-compose.yaml
```

![Редактирование compose.yaml с добавлением include](/screenshots/Screenshot_16.png)

### Повторный запуск — оба сервиса запущены (скриншот)

```bash
docker compose up -d
```

![docker compose up -d — запущены portainer и registry](/screenshots/Screenshot_17.png)

### Загрузка образа custom-nginx в локальный registry (скриншот)

```bash
docker tag custom-nginx:1.0.0 127.0.0.1:5000/custom-nginx:latest
docker push 127.0.0.1:5000/custom-nginx:latest
```

![Push образа в локальный registry](/screenshots/Screenshot_18.png)

### Portainer — список стеков (скриншот)

Стек `custom-nginx-stack` задеплоен через Portainer Web Editor со следующим compose:

```yaml
version: '3'

services:
  nginx:
    image: 127.0.0.1:5000/custom-nginx
    ports:
      - "9090:80"
```

![Portainer — список стеков](/screenshots/Screenshot_19.png)

### Portainer — Inspect контейнера nginx (скриншот)

Поля от **AppArmorProfile** до **Driver**:

![Portainer Inspect контейнера nginx](/screenshots/Screenshot_20.png)

### Удаление compose.yaml и предупреждение об orphan-контейнерах (скриншот)

```bash
rm compose.yaml && docker compose up -d
```

![Удаление compose.yaml и предупреждение об orphan-контейнерах](/screenshots/Screenshot_21.png)

**Объяснение предупреждения:** После удаления `compose.yaml` Docker Compose обнаружил контейнер `task5-portainer-1`, который был создан в рамках этого же проекта (task5), но больше не описан ни в одном из активных compose-файлов. Такие контейнеры называются **"orphan"** (осиротевшие). Docker предлагает удалить их с помощью флага `--remove-orphans`.

### Выполнение предложенного действия и остановка проекта одной командой (скриншот)

```bash
docker compose up -d --remove-orphans && docker compose down
```

![docker compose up --remove-orphans && docker compose down](/screenshots/Screenshot_22.png)

Все контейнеры и сети проекта успешно удалены одной командой `docker compose down`.
