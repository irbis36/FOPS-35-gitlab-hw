# Домашнее задание к занятию «Организация сети»

## Автор: Ларин Владимир

---

## Задание 1. Yandex Cloud

### 1. Создание VPC и подсетей

Для начала я установил провайдер Yandex Cloud через `terraform init`. Всё скачалось штатно, провайдер версии 0.218.0.

![terraform init](screenshot/Screenshot_1.png)

### 2. Применение конфигурации

Запустил `terraform apply -auto-approve`. Terraform создал 7 ресурсов — сеть, две подсети, таблицу маршрутизации, NAT-инстанс, публичную и приватную ВМ. Всё создалось без ошибок.

Результаты:

- NAT-инстанс внешний IP: `158.160.45.69`
- Публичная ВМ внешний IP: `89.169.137.244`
- Публичная ВМ внутренний IP: `192.168.10.27`
- Приватная ВМ внутренний IP: `192.168.20.10`

![terraform apply](screenshot/Screenshot_2.png)

### 3. Проверка доступа в интернет с публичной ВМ

Подключился по SSH к публичной ВМ и запустил `ping ya.ru`. Пинг прошёл, пакеты не теряются — значит интернет работает.

```
PING ya.ru (77.88.44.242) 56(84) bytes of data.
64 bytes from ya.ru (77.88.44.242): icmp_seq=1 ttl=56 time=5.63 ms
64 bytes from ya.ru (77.88.44.242): icmp_seq=2 ttl=56 time=5.21 ms
64 bytes from ya.ru (77.88.44.242): icmp_seq=3 ttl=56 time=5.29 ms
--- ya.ru ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
```

![ping с публичной ВМ](screenshot/Screenshot_3.png)

### 4. Проверка доступа в интернет с приватной ВМ

Через публичную ВМ подключился к приватной (192.168.20.10) и тоже пинганул `ya.ru`. Тоже работает — трафик идёт через NAT-инстанс, как и задумано.

```
PING ya.ru (5.255.255.242) 56(84) bytes of data.
64 bytes from ya.ru (5.255.255.242): icmp_seq=1 ttl=52 time=2.85 ms
64 bytes from ya.ru (5.255.255.242): icmp_seq=2 ttl=52 time=0.857 ms
64 bytes from ya.ru (5.255.255.242): icmp_seq=3 ttl=52 time=0.826 ms
--- ya.ru ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
```

![ping с приватной ВМ](screenshot/Screenshot_4.png)

### 5. Код Terraform (main.tf)

```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  service_account_key_file = "/home/larin/authorized_key.json"
  zone      = "ru-central1-a"
}
variable "cloud_id" {}
variable "folder_id" {}
# Сеть
resource "yandex_vpc_network" "net" {
  name = "my-network"
}
# Публичная подсеть
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
# Приватная подсеть
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route.id
}
# Таблица маршрутизации для приватной подсети
resource "yandex_vpc_route_table" "nat_route" {
  name       = "nat-route"
  network_id = yandex_vpc_network.net.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}
# NAT-инстанс
resource "yandex_compute_instance" "nat" {
  name        = "nat-instance"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
# Публичная ВМ
resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
# Приватная ВМ
resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
# Выводы
output "public_vm_external_ip" {
  value = yandex_compute_instance.public_vm.network_interface.0.nat_ip_address
}
output "public_vm_internal_ip" {
  value = yandex_compute_instance.public_vm.network_interface.0.ip_address
}
output "private_vm_internal_ip" {
  value = yandex_compute_instance.private_vm.network_interface.0.ip_address
}
output "nat_instance_external_ip" {
  value = yandex_compute_instance.nat.network_interface.0.nat_ip_address
}
```

---

В общем всё получилось — VPC создана, подсети настроены, NAT работает, с обеих ВМ есть доступ в интернет. Приватная ВМ ходит в интернет через NAT-инстанс благодаря таблице маршрутизации.

