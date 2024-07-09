terraform {
  backend "gcs" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    prefix = "terraform/vault/terraform.tfstate"
  }
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "17.1.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.google_region
}

provider "vault" {
  skip_tls_verify = "true"
}

provider "gitlab" {
  token = var.gitlab_token
}
