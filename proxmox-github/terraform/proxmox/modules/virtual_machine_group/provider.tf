terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.3"
    }
  }
}


# provider "proxmox" {
#   endpoint = var.virtual_environment_endpoint
#   apitoken = var.virtual_environment_api_token
#   # ssh {
#   #   agent       = false
#   #   username    = var.virtual_environment_ssh_username
#   #   private_key = file("${var.virtual_environment_private_key}")
#   # }
# }
