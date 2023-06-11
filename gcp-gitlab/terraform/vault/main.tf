terraform {
  terraform {
    backend "gcs" {
      bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
      prefix = "terraform/vault/terraform.tfstate"
    }
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
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vault" {
  skip_tls_verify = "true"
}
