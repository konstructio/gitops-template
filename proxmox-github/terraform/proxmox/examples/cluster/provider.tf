terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.0-alpha.0"
    }
  }
}

provider "talos" {
}

provider "proxmox" {
  endpoint  = var.virtual_environment_endpoint
  api_token = var.virtual_environment_api_token
  insecure  = true
}
