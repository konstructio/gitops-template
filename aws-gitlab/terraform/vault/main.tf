terraform {
  backend "s3" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key    = "terraform/vault/terraform.tfstate"

    region  = "<CLOUD_REGION>"
    encrypt = true
  }
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "17.1.0"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vault" {
  skip_tls_verify = "true"
}

provider "gitlab" {
  token = var.gitlab_token
}
