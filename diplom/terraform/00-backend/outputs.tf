output "bucket_name" {
  description = "Имя бакета для хранения стейта"
  value       = yandex_storage_bucket.tfstate.bucket
}

output "sa_id" {
  description = "Идентификатор сервисного аккаунта"
  value       = yandex_iam_service_account.tf.id
}

output "access_key" {
  description = "Ключ доступа к бакету"
  value       = yandex_iam_service_account_static_access_key.tf.access_key
  sensitive   = true
}

output "secret_key" {
  description = "Секретный ключ доступа к бакету"
  value       = yandex_iam_service_account_static_access_key.tf.secret_key
  sensitive   = true
}
