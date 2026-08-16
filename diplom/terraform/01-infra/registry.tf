resource "yandex_container_registry" "main" {
  name      = "diplom-registry"
  folder_id = var.folder_id
}

# Отдельный аккаунт для CI: ему нужно только пушить образы
resource "yandex_iam_service_account" "ci" {
  name        = "diplom-ci-sa"
  description = "SA для сборки и публикации образов"
  folder_id   = var.folder_id
}

resource "yandex_container_registry_iam_binding" "ci_push" {
  registry_id = yandex_container_registry.main.id
  role        = "container-registry.images.pusher"
  members     = ["serviceAccount:${yandex_iam_service_account.ci.id}"]
}

# Кластеру достаточно прав на чтение
resource "yandex_iam_service_account" "puller" {
  name        = "diplom-puller-sa"
  description = "SA для загрузки образов в кластер"
  folder_id   = var.folder_id
}

resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.main.id
  role        = "container-registry.images.puller"
  members     = ["serviceAccount:${yandex_iam_service_account.puller.id}"]
}
