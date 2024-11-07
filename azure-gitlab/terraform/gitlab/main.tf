terraform {
  backend "azurerm" {
    container_name       = "<KUBEFIRST_STATE_STORE_CONTAINER_NAME>"
    key                  = "gitlab/terraform.tfstate"
    resource_group_name  = "<KUBEFIRST_STATE_STORE_RESOURCE_GROUP>"
    storage_account_name = "<KUBEFIRST_STATE_STORE_BUCKET>"
  }
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "15.8.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
