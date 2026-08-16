# Мастеру и первому воркеру адреса закреплены: при остановке ВМ они
# сохранятся, и не придётся править kubeconfig с inventory.
# Второй воркер живёт на эфемерном адресе — квота на статические
# в каталоге ограничена, а для работы кластера это некритично.
resource "yandex_vpc_address" "static" {
  for_each = toset(["master", "worker-1"])

  name = "diplom-${each.key}-ip"

  external_ipv4_address {
    zone_id = var.zones[each.key == "master" ? 0 : 1]
  }
}
