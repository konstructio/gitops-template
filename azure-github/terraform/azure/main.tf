terraform {
  backend "azurerm" {
    container_name       = "terraform"
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
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  cluster_name         = "<CLUSTER_NAME>"
  dns_zone             = "<AZURE_DNS_ZONE_NAME>"
  dns_zone_rg          = "<AZURE_DNS_ZONE_RESOURCE_GROUP>"
  kube_config_filename = "../../../kubeconfig"
  kubernetes_version   = "1.29.7" # Latest stable at time of writing
  node_count           = tonumber("<NODE_COUNT>")
  tags = {
    ClusterName   = local.cluster_name
    kubefirst     = "true"
    ProvisionedBy = "kubefirst"
  }
  use_dns_zone = try(local.dns_zone != "" && local.dns_zone_rg != "", false)
  vm_size      = "<NODE_TYPE>"
}

# All resources must be created in a resource group - the location will be inferred from this
resource "azurerm_resource_group" "kubefirst" {
  name     = local.cluster_name
  location = "<CLOUD_REGION>"

  tags = local.tags
}
