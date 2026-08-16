# Суффикс, чтобы имя бакета было уникальным на весь Object Storage
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Сервисный аккаунт, от имени которого Terraform управляет инфраструктурой
resource "yandex_iam_service_account" "tf" {
  name        = var.sa_name
  description = "SA для Terraform, дипломный проект"
  folder_id   = var.folder_id
}

# Права выдаём точечно, без роли admin на каталог
locals {
  sa_roles = [
    "storage.admin",
    "vpc.admin",
    "compute.admin",
    "container-registry.admin",
    "load-balancer.admin",
    "iam.serviceAccounts.user",
  ]
}

resource "yandex_resourcemanager_folder_iam_member" "tf" {
  for_each  = toset(local.sa_roles)
  folder_id = var.folder_id
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.tf.id}"
}

# Статический ключ нужен, потому что S3-бекенд ходит по AWS-совместимому протоколу
resource "yandex_iam_service_account_static_access_key" "tf" {
  service_account_id = yandex_iam_service_account.tf.id
  description        = "Ключ для доступа к бакету со стейтом"
  depends_on         = [yandex_resourcemanager_folder_iam_member.tf]
}

resource "yandex_storage_bucket" "tfstate" {
  bucket     = "diplom-tfstate-${random_string.suffix.result}"
  access_key = yandex_iam_service_account_static_access_key.tf.access_key
  secret_key = yandex_iam_service_account_static_access_key.tf.secret_key

  # Версионирование пригодится, если стейт случайно испортится
  versioning {
    enabled = true
  }

  anonymous_access_flags {
    read = false
    list = false
  }
}
