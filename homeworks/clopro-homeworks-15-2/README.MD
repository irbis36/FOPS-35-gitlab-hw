# Домашнее задание: Вычислительные мощности. Балансировщики нагрузки

## Автор: Ларин Владимир

---

## Задание 1. Yandex Cloud

### 1. Создание бакета Object Storage

Создал бакет `larin-23-07-2026` в Object Storage и загрузил туда картинку `picture.jpg`. Настроил публичный доступ на чтение, чтобы картинка была доступна из интернета.

Ссылка на картинку: `https://storage.yandexcloud.net/larin-23-07-2026/picture.jpg`

Проверил доступность через curl — получил ответ 200:

```
curl -s -o /dev/null -w "%{http_code}" https://storage.yandexcloud.net/larin-23-07-2026/picture.jpg
200
```

*Скриншот бакета в консоли — screenshot3.png*

### 2. Создание группы ВМ с шаблоном LAMP

Создал Instance Group из 3 виртуальных машин с образом LAMP (`image_id = fd827b91d99psvq5fjit`). В `user-data` прописал скрипт, который при запуске генерирует `index.html` со ссылкой на картинку из бакета.

Настроил health check по HTTP на порт 80.

Список созданных ВМ:

```
+----------------------+---------------------------+---------------+---------+----------------+-------------+
|          ID          |           NAME            |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+---------------------------+---------------+---------+----------------+-------------+
| fhm3pd33fi82rb9qualv | cl12abfrk03bca2r2hp8-yjiz | ru-central1-a | RUNNING | 158.160.32.196 | 10.128.0.22 |
| fhm46c7mdihdld605tt6 | cl12abfrk03bca2r2hp8-imiq | ru-central1-a | RUNNING | 158.160.37.217 | 10.128.0.29 |
| fhma622vc0lm23rkdkau | cl12abfrk03bca2r2hp8-avem | ru-central1-a | RUNNING | 158.160.50.60  | 10.128.0.11 |
+----------------------+---------------------------+---------------+---------+----------------+-------------+
```

*Скриншот веб-страницы через балансировщик — screenshot1.png*

### 3. Сетевой балансировщик

Создал Network Load Balancer `lamp-load-balancer`, который слушает на порту 80 и направляет трафик на target group из Instance Group.

IP-адрес балансировщика: `158.160.140.31`

Проверка — страница открывается, curl возвращает 200:

```
curl -s -o /dev/null -w "%{http_code}" http://158.160.140.31
200
```

### 4. Проверка отказоустойчивости

Удалил одну ВМ вручную командой `yc compute instance delete`. После удаления балансировщик продолжил работать, а Instance Group автоматически начала создавать новую ВМ на замену:

```
+----------------------+---------------------------+---------------+--------------+----------------+-------------+
|          ID          |           NAME            |    ZONE ID    |    STATUS    |  EXTERNAL IP   | INTERNAL IP |
+----------------------+---------------------------+---------------+--------------+----------------+-------------+
| fhm46c7mdihdld605tt6 | cl12abfrk03bca2r2hp8-imiq | ru-central1-a | RUNNING      | 158.160.37.217 | 10.128.0.29 |
| fhma622vc0lm23rkdkau | cl12abfrk03bca2r2hp8-avem | ru-central1-a | RUNNING      | 158.160.50.60  | 10.128.0.11 |
| fhmmd700dp008974skus | cl12abfrk03bca2r2hp8-yjiz | ru-central1-a | PROVISIONING | 93.77.183.196  | 10.128.0.33 |
+----------------------+---------------------------+---------------+--------------+----------------+-------------+
```

Видно что новая ВМ уже в статусе PROVISIONING — группа сама восстанавливает нужное количество.

Сайт при этом продолжал работать без перебоев.

*Скриншот сайта после удаления ВМ — screenshot2.png*

---

## Код Terraform

```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = "/home/larin/authorized_key.json"
  cloud_id                 = "b1g1mgid1ed7871co3ni"
  folder_id                = "b1gu8qpiq39a5hunc1h2"
  zone                     = "ru-central1-a"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "ajeeusto92auktkb44m9"
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "larin-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "larin-23-07-2026"

  anonymous_access_flags {
    read = true
  }
}

resource "yandex_storage_object" "picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.larin-bucket.id
  key        = "picture.jpg"
  source     = "unnamed.jpg"
}

resource "yandex_compute_instance_group" "lamp-group" {
  name               = "lamp-group"
  folder_id          = "b1gu8qpiq39a5hunc1h2"
  service_account_id = "ajeeusto92auktkb44m9"

  instance_template {
    platform_id = "standard-v1"

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }

    network_interface {
      network_id = "enp3pc9ttujfdchovomp"
      subnet_ids = ["e9b7db52116hf7t9cca2"]
      nat        = true
    }

    metadata = {
      ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data = <<-USERDATA
        #!/bin/bash
        echo '<html><body><h1>Larin - LAMP Server</h1><img src="https://storage.yandexcloud.net/larin-23-07-2026/picture.jpg"></body></html>' > /var/www/html/index.html
      USERDATA
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  load_balancer {
    target_group_name = "lamp-target-group"
  }

  health_check {
    interval = 10
    timeout  = 5
    http_options {
      port = 80
      path = "/"
    }
  }
}

resource "yandex_lb_network_load_balancer" "lb" {
  name = "lamp-load-balancer"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp-group.load_balancer[0].target_group_id

    healthcheck {
      name = "http-check"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

output "lb_ip" {
  value = yandex_lb_network_load_balancer.lb.listener[*].external_address_spec[*]
}

output "bucket_url" {
  value = "https://storage.yandexcloud.net/${yandex_storage_bucket.larin-bucket.bucket}/picture.jpg"
}
```

---

В целом всё получилось — бакет работает, картинка доступна, группа ВМ автоматически восстанавливается, балансировщик раздаёт трафик. При удалении одной ВМ сайт не падал, новая машина поднялась сама.
