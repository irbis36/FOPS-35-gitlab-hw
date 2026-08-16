variable "cloud_id" {
  description = "Идентификатор облака"
  type        = string
}

variable "folder_id" {
  description = "Идентификатор каталога"
  type        = string
}

variable "default_zone" {
  description = "Зона по умолчанию"
  type        = string
  default     = "ru-central1-a"
}

variable "sa_name" {
  description = "Имя сервисного аккаунта для Terraform"
  type        = string
  default     = "diplom-tf-sa"
}
