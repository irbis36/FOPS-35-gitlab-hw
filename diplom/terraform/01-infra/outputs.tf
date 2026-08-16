output "network_id" {
  value = yandex_vpc_network.main.id
}

output "subnet_ids" {
  value = yandex_vpc_subnet.main[*].id
}

output "nodes" {
  description = "Адреса нод кластера"
  value = {
    for k, v in yandex_compute_instance.k8s : k => {
      internal_ip = v.network_interface.0.ip_address
      external_ip = v.network_interface.0.nat_ip_address
      zone        = v.zone
    }
  }
}

output "master_external_ip" {
  value = yandex_compute_instance.k8s["master"].network_interface.0.nat_ip_address
}

output "registry_id" {
  description = "Идентификатор реестра образов"
  value       = yandex_container_registry.main.id
}

output "ci_sa_id" {
  value = yandex_iam_service_account.ci.id
}

output "puller_sa_id" {
  value = yandex_iam_service_account.puller.id
}
