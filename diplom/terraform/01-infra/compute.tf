data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

locals {
  # Мастер один, потому что купон ограничен. Воркеров два, оба прерываемые.
  nodes = {
    "master" = {
      zone_index  = 0
      cores       = 2
      memory      = 4
      fraction    = 50
      preemptible = false
      disk_type   = "network-ssd"
      disk_size   = 30
    }
    "worker-1" = {
      zone_index  = 1
      cores       = 2
      memory      = 4
      fraction    = 20
      preemptible = true
      disk_type   = "network-hdd"
      disk_size   = 30
    }
    "worker-2" = {
      zone_index  = 2
      cores       = 2
      memory      = 4
      fraction    = 20
      preemptible = true
      disk_type   = "network-hdd"
      disk_size   = 30
    }
  }
}

resource "yandex_compute_instance" "k8s" {
  for_each = local.nodes

  name        = "diplom-${each.key}"
  hostname    = "diplom-${each.key}"
  zone        = var.zones[each.value.zone_index]
  platform_id = "standard-v3"

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = each.value.disk_type
      size     = each.value.disk_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.main[each.value.zone_index].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s.id]
  }

  scheduling_policy {
    preemptible = each.value.preemptible
  }

  metadata = {
    ssh-keys  = "ubuntu:${file(var.ssh_public_key_path)}"
    user-data = <<-EOT
      #cloud-config
      users:
        - name: ubuntu
          groups: sudo
          shell: /bin/bash
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          ssh_authorized_keys:
            - ${file(var.ssh_public_key_path)}
    EOT
  }

  allow_stopping_for_update = true
}
