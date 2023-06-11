# google_client_config and kubernetes provider must be explicitly specified like the following.

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source = "terraform-google-modules/kubernetes-engine/google"

  name            = var.cluster_name
  project_id      = var.project
  region          = var.gcp_region
  release_channel = "STABLE"

  // Service Account
  create_service_account = true

  // Networking
  network           = var.network
  subnetwork        = var.subnetwork
  ip_range_pods     = "${var.subnetwork}-gke-01-pods"
  ip_range_services = "${var.subnetwork}-gke-01-services"

  // Addons
  dns_cache                  = true
  enable_shielded_nodes      = true
  filestore_csi_driver       = false
  gce_pd_csi_driver          = true
  horizontal_pod_autoscaling = false
  http_load_balancing        = false
  network_policy             = false

  // Node Pools
  node_pools = [
    {
      name         = "kubefirst"
      machine_type = var.instance_type

      // Autoscaling
      // PER ZONE
      min_count = 1
      // PER ZONE
      max_count = 2
      // PER ZONE
      initial_node_count = 1

      local_ssd_count = 0
      spot            = false
      disk_size_gb    = 100
      disk_type       = "pd-standard"
      image_type      = "COS_CONTAINERD"
      enable_gcfs     = false
      enable_gvnic    = false
      auto_repair     = true
      auto_upgrade    = true
      preemptible     = false
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = var.cluster_name
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = []
  }

  node_pools_tags = {
    all = [
      var.cluster_name,
    ]

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
