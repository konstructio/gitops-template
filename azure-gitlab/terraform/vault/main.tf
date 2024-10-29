terraform {
  backend "azurerm" {
    container_name       = "<KUBEFIRST_STATE_STORE_CONTAINER_NAME>"
    key                  = "vault/terraform.tfstate"
    resource_group_name  = "<KUBEFIRST_STATE_STORE_RESOURCE_GROUP>"
    storage_account_name = "<KUBEFIRST_STATE_STORE_BUCKET>"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.2.0, < 5.0.0"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "vault" {
  skip_tls_verify = "true"
}
