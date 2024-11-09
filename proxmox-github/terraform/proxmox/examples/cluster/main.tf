module "cluster" {
  source = "../../modules/cluster"

  virtual_environment_node_name   = var.virtual_environment_node_name
  cluster_name                    = var.cluster_name
  talos_version                   = var.talos_version
  tags                            = var.tags
  virtual_environment_image_store = var.image_store
  virtual_environment_data_store  = var.data_store
  ipv4                            = var.ipv4

  controlplane = var.controlplane

  dataplane = var.dataplane
}

# output "ipv4" {
#   value = module.cluster.ipv4_address
# }
