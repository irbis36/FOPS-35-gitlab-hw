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

resource "yandex_kms_symmetric_key" "bucket-key" {
  name              = "bucket-encryption-key"
  description       = "ключ для шифрования бакета"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "ajeeusto92auktkb44m9"
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "larin-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "larin-encrypted-23-07-2026"

  anonymous_access_flags {
    read = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "yandex_storage_object" "picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.larin-bucket.id
  key        = "picture.jpg"
  source     = "/home/larin/clopro-homeworks-15-2/unnamed.jpg"
}

output "kms_key_id" {
  value = yandex_kms_symmetric_key.bucket-key.id
}

output "bucket_name" {
  value = yandex_storage_bucket.larin-bucket.bucket
}
