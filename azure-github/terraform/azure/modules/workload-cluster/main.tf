module "base" {
  source = "../base"

  cluster_name   = var.cluster_name
  cluster_region = var.cluster_region
  extra_tags = {
    Type                = "workspace"
    ManagementClusterID = "<CLUSTER_ID>"
  }
  node_count  = var.node_count
  node_type   = var.node_type
  dns_zone    = local.dns_zone
  dns_zone_rg = local.dns_zone_rg
}

locals {
  dns_zone    = "<AZURE_DNS_ZONE_NAME>"
  dns_zone_rg = "<AZURE_DNS_ZONE_RESOURCE_GROUP>"
}
