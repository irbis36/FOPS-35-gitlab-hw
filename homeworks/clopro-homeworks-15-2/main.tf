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

# ===== Бакет Object Storage =====

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

# ===== Instance Group с LAMP =====

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

# ===== Сетевой балансировщик =====

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

# ===== Outputs =====

output "lb_ip" {
  value = yandex_lb_network_load_balancer.lb.listener[*].external_address_spec[*]
}

output "bucket_url" {
  value = "https://storage.yandexcloud.net/${yandex_storage_bucket.larin-bucket.bucket}/picture.jpg"
}
