module "gke" {
  source = "./gke"

  cluster_name  = local.cluster_name
  google_region = var.google_region
  project       = var.project

  network    = module.vpc.network_name
  subnetwork = lookup(module.vpc.subnets, "${var.google_region}/subnet-01-${local.cluster_name}").name
}
