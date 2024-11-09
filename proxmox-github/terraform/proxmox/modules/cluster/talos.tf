locals {

  nodes     = [for i in concat(var.controlplane.ipv4_address, var.dataplane.ipv4_address) : split("/", i)[0]]
  endpoints = [for i in var.controlplane.ipv4_address : split("/", i)[0]]
  worker    = [for i in var.dataplane.ipv4_address : split("/", i)[0]]

}

// talos_image_factory_schematic
resource "proxmox_virtual_environment_download_file" "this" {
  content_type = "iso"
  datastore_id = var.virtual_environment_image_store
  node_name    = var.virtual_environment_node_name
  # TODO - use talos_version variable
  url = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.8.1/nocloud-amd64.iso"
}

resource "talos_machine_secrets" "this" {
  # talos_version = var.cluster.talos_version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  // what is the difference between nodes and endpoints
  nodes = local.nodes
  # endpoints  = module.controlplane_nodes.ipv4_address[0]
  endpoints  = local.endpoints
  depends_on = [module.controlplane_nodes, module.dataplane_nodes]
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${local.endpoints[0]}:6443/"
  # talos_version    = var.cluster.talos_version
  machine_type    = "controlplane"
  machine_secrets = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "dataplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${local.endpoints[0]}:6443/"
  # talos_version    = var.cluster.talos_version
  machine_type    = "worker"
  machine_secrets = talos_machine_secrets.this.machine_secrets
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = toset(var.controlplane.ipv4_address)

  node                        = split("/", each.value)[0]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  # lifecycle {
  #   replace_triggered_by = [proxmox_virtual_environment_vm.this[each.key]]
  # }
  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.1"
        }
      }
    })
  ]

}

resource "talos_machine_configuration_apply" "dataplane" {
  for_each = toset(var.dataplane.ipv4_address)

  node                        = split("/", each.value)[0]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.dataplane.machine_configuration
  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.1"
        }
      }
    })
  ]

  depends_on = [resource.talos_machine_configuration_apply.controlplane]
}

resource "talos_machine_bootstrap" "controlplane" {
  # endpoint             = "https://${local.endpoints[0]}:6443/"
  node                 = local.endpoints[0]
  client_configuration = talos_machine_secrets.this.client_configuration
  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]
}


# data "talos_cluster_health" "this" {
#   depends_on = [
#     # talos_machine_configuration_apply.this,
#     talos_machine_bootstrap.controlplane
#   ]
#   client_configuration = data.talos_client_configuration.this.client_configuration
#   control_plane_nodes  = local.endpoints
#   worker_nodes         = local.worker
#   endpoints            = data.talos_client_configuration.this.endpoints
#   timeouts = {
#     read = "10m"
#   }
# }
