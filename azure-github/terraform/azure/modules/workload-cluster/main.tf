provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.kubefirst.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.cluster_ca_certificate)
}

locals {
  dns_zone           = "<AZURE_DNS_ZONE_NAME>"
  dns_zone_rg        = "<AZURE_DNS_ZONE_RESOURCE_GROUP>"
  kubernetes_version = "1.29."
  tags = {
    ClusterName         = var.cluster_name
    ProvisionedBy       = "kubefirst"
    Type                = "workload"
    ManagementClusterID = "<CLUSTER_ID>"
  }
  use_dns_zone = try(local.dns_zone != "" && local.dns_zone_rg != "", false)
}

# All resources must be created in a resource group - the location will be inferred from this
resource "azurerm_resource_group" "kubefirst" {
  name     = var.cluster_name
  location = var.cluster_region

  tags = local.tags
}

data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_service_versions" "current" {
  location        = var.cluster_region
  version_prefix  = local.kubernetes_version
  include_preview = false
}
