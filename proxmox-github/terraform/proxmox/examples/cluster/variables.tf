variable "virtual_environment_endpoint" {
  type        = string
  description = "Proxmox host IP address or domain"
}

variable "virtual_environment_api_token" {
  type = string
}

variable "virtual_environment_node_name" {
  type        = string
  description = "Proxmox node to create virtual machine in."
}

variable "cluster_name" {
  type = string
}

variable "talos_version" {
  type = string
}

variable "tags" {
  type = list(string)
}

variable "image_store" {
  type = string
}

variable "data_store" {
  type = string
}

# variable "controlplane_node_count" {
#   type = number
# }

# variable "controlplane_cpu_cores" {
#   type = number
# }

# variable "controlplane_memory" {
#   type = number
# }

# variable "controlplane_disk_size" {
#   type = number
# }

# variable "dataplane_node_count" {
#   type = number
# }

# variable "dataplane_cpu_cores" {
#   type = number
# }

# variable "dataplane_memory" {
#   type = number
# }

# variable "dataplane_disk_size" {
#   type = number
# }

variable "controlplane" {
  type = object({
    ipv4_address = list(string)
    resource = object({
      cpu_cores = number
      memory    = number
      disk_size = number
    })
  })
}


variable "dataplane" {

  type = object({
    ipv4_address = list(string)
    resource = object({
      cpu_cores = number
      memory    = number
      disk_size = number
    })
  })
}


variable "ipv4" {
  type = object({
    # method  = string
    address = string
    gateway = optional(string)
  })
  // validation
}

variable "dns" {
  type = object({
    domain       = string
    name_servers = list(string)
  })
}
