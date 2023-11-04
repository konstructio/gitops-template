resource "google_compute_router" "router" {
  name    = "gke-cloud-router-${var.cluster_name}"
  project = var.project
  network = var.network
  region  = var.google_region
}

module "cloud-nat" {
  name                               = "gke-nat-config-${var.cluster_name}"
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 5.0"
  project_id                         = var.project
  region                             = var.google_region
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
