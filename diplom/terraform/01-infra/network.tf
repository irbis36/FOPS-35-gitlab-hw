resource "yandex_vpc_network" "main" {
  name        = "diplom-net"
  description = "Сеть дипломного проекта"
}

# По подсети в каждой зоне — требование задания.
# Таблицу маршрутов не подключаем: у нод есть публичные адреса,
# а NAT-шлюз на подсети ломает входящие соединения на них.
resource "yandex_vpc_subnet" "main" {
  count          = length(var.zones)
  name           = "diplom-subnet-${var.zones[count.index]}"
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.cidrs[count.index]]
}
