variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zones" {
  description = "Зоны доступности для подсетей"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

variable "cidrs" {
  description = "Адресация подсетей, по одной на зону"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "ssh_public_key_path" {
  description = "Публичный ключ лежит рядом с конфигурацией, чтобы она работала и на раннере CI"
  type        = string
  default     = "ssh-key.pub"
}
