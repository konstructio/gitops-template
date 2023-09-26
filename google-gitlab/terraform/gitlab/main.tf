terraform {
  backend "gcs" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    prefix = "terraform/gitlab/terraform.tfstate"
  }
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "15.8.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
  }
}
