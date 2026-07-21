locals {
  project  = "netology"
  env      = "develop"
  role_web = "platform-web"
  role_db  = "platform-db"

  vm_web_name = "${local.project}-${local.env}-${local.role_web}"
  vm_db_name  = "${local.project}-${local.env}-${local.role_db}"
}
