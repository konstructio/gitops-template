module "civo_kubernetes_cluster" {
  source          = "${path.module}/../civo-cluster"
  cluster_name    = var.cluster_name
  cluster_region  = var.cluster_region
  environment     = var.environment
  node_count      = var.node_count
  node_type       = var.node_type
  cluster_type    = var.cluster_type
  labels          = {}
  mgmt_cluster_id = "<CLUSTER_ID>"
}
