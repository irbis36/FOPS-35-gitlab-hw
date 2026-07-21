vms_resources = {
  web = {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
  db = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}

metadata = {
  serial-port-enable = 1
  ssh-keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKa3CrPHPD7wUIsTpySMfLiSXfQ+mwptOmr7HDXI0Gh2 root@deb-13-netology"
}
