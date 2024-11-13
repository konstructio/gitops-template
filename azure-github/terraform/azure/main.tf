terraform {
  backend "azurerm" {
    container_name       = "<KUBEFIRST_STATE_STORE_CONTAINER_NAME>"
    key                  = "azure/terraform.tfstate"
    resource_group_name  = "<KUBEFIRST_STATE_STORE_RESOURCE_GROUP>"
    storage_account_name = "<KUBEFIRST_STATE_STORE_BUCKET>"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.2.0, < 5.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.2, < 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.32.0, < 3.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.kubefirst.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.cluster_ca_certificate)
}

locals {
  cluster_name         = "<CLUSTER_NAME>"
  dns_zone             = "<AZURE_DNS_ZONE_NAME>"
  dns_zone_rg          = "<AZURE_DNS_ZONE_RESOURCE_GROUP>"
  kube_config_filename = "../../../kubeconfig"
  kubernetes_version   = "1.29."
  location             = "<CLOUD_REGION>"
  node_count           = tonumber("<NODE_COUNT>")
  tags = {
    ClusterName   = local.cluster_name
    ProvisionedBy = "kubefirst"
    Type          = "management"
  }
  use_dns_zone = try(local.dns_zone != "", false)
  vm_size      = "<NODE_TYPE>"
}

# All resources must be created in a resource group - the location will be inferred from this
resource "azurerm_resource_group" "kubefirst" {
  name     = local.cluster_name
  location = local.location

  tags = local.tags
}

data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_service_versions" "current" {
  location        = local.location
  version_prefix  = local.kubernetes_version
  include_preview = false
}
