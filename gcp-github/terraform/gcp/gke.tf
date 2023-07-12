module "gke" {
  source = "./gke"

  cluster_name = local.cluster_name
  gcp_region   = var.gcp_region
  project      = var.project

  network    = module.vpc.network_name
  subnetwork = lookup(module.vpc.subnets, "${var.gcp_region}/subnet-01").name
}
