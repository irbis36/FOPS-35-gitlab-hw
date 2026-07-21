data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

locals {
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}
