resource "local_file" "inventory" {
  content = templatefile("${path.module}/hosts.tftpl", {
    webservers = yandex_compute_instance.web
    databases  = [for k, v in yandex_compute_instance.db : v]
    storage    = [yandex_compute_instance.storage]
  })
  filename = "${abspath(path.module)}/hosts.ini"
}
