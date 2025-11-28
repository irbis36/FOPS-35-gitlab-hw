# Домашнее задание RabbitMQ
# Ларин Владимир

---

## Задание 1. Установка RabbitMQ

**Ответ:**  
Установлен RabbitMQ, включён management plugin, выполнен вход в веб‑интерфейс.

**Скриншот веб‑интерфейса (вставьте сюда):**
![RabbitMQ](https://raw.githubusercontent.com/irbis36/FOPS-35-gitlab-hw/main/screenshots/rabbitmq/1.png)

---

## Задание 2. Отправка и получение сообщений

**Ответ:**  
Настроены скрипты *producer.py* и *consumer.py*, IP заменён на нужный.  
Сообщение отправлено и получено успешно.

**Скрин очереди hello:**  
![hello](https://raw.githubusercontent.com/irbis36/FOPS-35-gitlab-hw/main/screenshots/rabbitmq/2.png)

**Скрин результата consumer.py:**  
![consymer.py](https://raw.githubusercontent.com/irbis36/FOPS-35-gitlab-hw/main/screenshots/rabbitmq/3.png)

---

## Задание 3. Подготовка HA кластера

Машины:

- rmq01 — 192.168.10.108  
- rmq02 — 192.168.10.117

**Ответ:**  
- Обе ноды установлены.  
- /etc/hosts настроен.  
- Кластер объединён.  
- Политика ha-all создана.

**Скрин состояния кластера (nodes):**  
![ha](https://raw.githubusercontent.com/irbis36/FOPS-35-gitlab-hw/main/screenshots/rabbitmq/4.png)

**Скрин политики ha-all:**  
![ha-all](https://raw.githubusercontent.com/irbis36/FOPS-35-gitlab-hw/main/screenshots/rabbitmq/5.png)

---

### Вывод cluster_status (вставить для каждой ноды)

```bash
root@rmq01:/home/larin/FOPS-35-gitlab-hw# sudo rabbitmqctl cluster_status
Cluster status of node rabbit@rmq01 ...
Basics

Cluster name: rabbit@rmq01

Disk Nodes

rabbit@rmq01
rabbit@rmq02

Running Nodes

rabbit@rmq01

Versions

rabbit@rmq01: RabbitMQ 3.8.2 on Erlang 22.2.7

Alarms

(none)

Network Partitions

(none)

Listeners

Node: rabbit@rmq01, interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
Node: rabbit@rmq01, interface: [::], port: 5672, protocol: amqp, purpose: AMQP 0-9-1 and AMQP 1.0
Node: rabbit@rmq01, interface: [::], port: 15672, protocol: http, purpose: HTTP API

Feature flags

Flag: drop_unroutable_metric, state: enabled
Flag: empty_basic_get_metric, state: enabled
Flag: implicit_default_bindings, state: enabled
Flag: quorum_queue, state: enabled
Flag: virtual_host_metadata, state: enabled
```

```bash
root@rmq02:/home/larin/FOPS-35-gitlab-hw# sudo rabbitmqctl cluster_status
Cluster status of node rabbit@rmq02 ...
Basics

Cluster name: rabbit@rmq01

Disk Nodes

rabbit@rmq01
rabbit@rmq02

Running Nodes

rabbit@rmq01
rabbit@rmq02

Versions

rabbit@rmq01: RabbitMQ 3.8.2 on Erlang 22.2.7
rabbit@rmq02: RabbitMQ 3.8.2 on Erlang 22.2.7

Alarms

(none)

Network Partitions

(none)

Listeners

Node: rabbit@rmq01, interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
Node: rabbit@rmq01, interface: [::], port: 5672, protocol: amqp, purpose: AMQP 0-9-1 and AMQP 1.0
Node: rabbit@rmq01, interface: [::], port: 15672, protocol: http, purpose: HTTP API
Node: rabbit@rmq02, interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
Node: rabbit@rmq02, interface: [::], port: 5672, protocol: amqp, purpose: AMQP 0-9-1 and AMQP 1.0
Node: rabbit@rmq02, interface: [::], port: 15672, protocol: http, purpose: HTTP API

Feature flags

Flag: drop_unroutable_metric, state: enabled
Flag: empty_basic_get_metric, state: enabled
Flag: implicit_default_bindings, state: enabled
Flag: quorum_queue, state: enabled
Flag: virtual_host_metadata, state: enabled

```


---

### Проверка очереди командой rabbitmqadmin get queue='hello'

**Скрин с rmq01:**  
![rmq](https://raw.githubusercontent.com/irbis36/FOPS-35-gitlab-hw/main/screenshots/rabbitmq/7.png)

---


