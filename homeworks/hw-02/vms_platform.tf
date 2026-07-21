###vm_web vars

# variable "vm_web_name" {
#   type        = string
#   default     = "netology-develop-platform-web"
#   description = "VM web name"
# }

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "VM platform id"
}

# variable "vm_web_cores" {
#   type        = number
#   default     = 2
#   description = "VM cores"
# }

# variable "vm_web_memory" {
#   type        = number
#   default     = 1
#   description = "VM memory in GB"
# }

# variable "vm_web_core_fraction" {
#   type        = number
#   default     = 5
#   description = "VM core fraction"
# }

variable "vm_web_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "VM image family"
}

variable "vm_web_preemptible" {
  type        = bool
  default     = true
  description = "VM preemptible"
}

variable "vm_web_nat" {
  type        = bool
  default     = true
  description = "VM NAT enabled"
}

###vm_db vars

# variable "vm_db_name" {
#   type        = string
#   default     = "netology-develop-platform-db"
#   description = "VM db name"
# }

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "VM db platform id"
}

# variable "vm_db_cores" {
#   type        = number
#   default     = 2
#   description = "VM db cores"
# }

# variable "vm_db_memory" {
#   type        = number
#   default     = 2
#   description = "VM db memory in GB"
# }

# variable "vm_db_core_fraction" {
#   type        = number
#   default     = 20
#   description = "VM db core fraction"
# }

variable "vm_db_preemptible" {
  type        = bool
  default     = true
  description = "VM db preemptible"
}

variable "vm_db_nat" {
  type        = bool
  default     = true
  description = "VM db NAT enabled"
}

variable "vm_db_zone" {
  type        = string
  default     = "ru-central1-b"
  description = "VM db zone"
}

variable "vm_db_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
  description = "VM db subnet CIDR"
}

###common vars

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
  description = "VM resources map"
}

variable "metadata" {
  type = map(any)
  description = "VM metadata map"
}
