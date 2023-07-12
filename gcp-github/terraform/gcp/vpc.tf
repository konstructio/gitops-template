module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.0"

  project_id   = var.project
  network_name = var.network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "subnet-01"
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = var.gcp_region
      subnet_private_access = "false"
      subnet_flow_logs      = "true"
      description           = "This base subnet."
    },
  ]

  secondary_ranges = {
    subnet-01 = [
      {
        range_name    = "subnet-01-gke-01-pods"
        ip_cidr_range = "10.13.0.0/16"
      },
      {
        range_name    = "subnet-01-gke-01-services"
        ip_cidr_range = "10.14.0.0/16"
      },
    ]
  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    },
  ]

  depends_on = [module.services]
}
