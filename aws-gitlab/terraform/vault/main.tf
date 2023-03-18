terraform {
  backend "s3" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key    = "terraform/vault/terraform.tfstate"

    region  = "<CLOUD_REGION>"
    encrypt = true
  }
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vault" {
  skip_tls_verify = "true"
}
