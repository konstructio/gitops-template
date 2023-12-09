module "gke" {
  source = "./gke"

  cluster_name  = var.cluster_name
  google_region = var.google_region
  project       = var.project
  node_count    = var.node_count
  network       = module.vpc.network_name
  subnetwork    = lookup(module.vpc.subnets, "${var.google_region}/subnet-01-${var.cluster_name}").name
}