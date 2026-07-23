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
