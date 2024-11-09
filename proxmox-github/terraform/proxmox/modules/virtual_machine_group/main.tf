resource "proxmox_virtual_environment_vm" "this" {
  for_each = { for i in range(length(var.ipv4_address)) : "${var.ng_name_prefix}-${i + 1}" => var.ipv4_address[i] }

  name      = each.key
  node_name = var.virtual_environment_node_name
  tags      = var.tags

  stop_on_destroy = true
  machine         = var.machine_type
  scsi_hardware   = "virtio-scsi-single"
  operating_system {
    type = "l26"
  }

  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory * 1024
  }

  boot_order = ["scsi0", "ide0"]

  cdrom {
    enabled   = true
    file_id   = var.cd_rom
    interface = "ide0"
  }
  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    ssd          = true
    discard      = "on"
    size         = var.disk_size
    file_format  = "raw"
  }

  network_device {
    bridge = var.bridge_device
  }

  agent {
    enabled = true
    trim    = true
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = each.value
        gateway = var.ipv4_gateway
      }
    }
    dns {
      domain  = "kubefirst.konstruct.home.arpa"
      servers = ["8.8.8.8"]
    }
  }
}
