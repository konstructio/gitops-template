
locals {
  # netmask      = split("/", var.ipv4.address)[1]
  # last_octet   = split(".", split("/", var.ipv4.address)[0])[3]
  # ctrl_pln_ips = { for i in range(var.controlplane.node_count) : "${var.cluster_name}-ctrpln-${i}" => "${cidrhost(var.ipv4.address, local.last_octet + i)}/${local.netmask}" }
  # wrk_pln_ips  = { for i in range(var.controlplane.node_count, var.controlplane.node_count + var.dataplane.node_count) : "${var.cluster_name}-datapln-${i}" => "${cidrhost(var.ipv4.address, local.last_octet + i)}/${local.netmask}" }
}


module "controlplane_nodes" {
  source = "../virtual_machine_group"

  virtual_environment_node_name = var.virtual_environment_node_name
  tags                          = var.tags
  ng_name_prefix                = "${var.cluster_name}-ctrlpln"
  cpu_cores                     = var.controlplane.resource.cpu_cores
  memory                        = var.controlplane.resource.memory
  cd_rom                        = proxmox_virtual_environment_download_file.this.id
  datastore_id                  = var.virtual_environment_data_store
  disk_size                     = var.controlplane.resource.disk_size
  ipv4_address                  = var.controlplane.ipv4_address
  ipv4_gateway                  = var.ipv4.gateway
  # dns                           = var.dns
}


module "dataplane_nodes" {
  source = "../virtual_machine_group"

  virtual_environment_node_name = var.virtual_environment_node_name
  tags                          = var.tags
  ng_name_prefix                = "${var.cluster_name}-datapln"
  cpu_cores                     = var.controlplane.resource.cpu_cores
  memory                        = var.controlplane.resource.memory
  cd_rom                        = proxmox_virtual_environment_download_file.this.id
  datastore_id                  = var.virtual_environment_data_store
  disk_size                     = var.controlplane.resource.disk_size
  ipv4_address                  = var.dataplane.ipv4_address
  ipv4_gateway                  = var.ipv4.gateway
  # dns                           = var.dns

  depends_on = [module.controlplane_nodes]
}
