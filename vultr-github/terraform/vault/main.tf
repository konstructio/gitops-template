terraform {
  backend "s3" {
    endpoint = "<KUBEFIRST_STATE_STORE_BUCKET_HOSTNAME>"
bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key      = "terraform/vault/terraform.tfstate"

    // Don't change this.
    // https://www.vultr.com/docs/how-to-store-terraform-state-in-vultr-object-storage/
    region = "us-east-1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
  required_providers {
    vultr = {
      source = "vultr/vultr"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vultr" {}

provider "vault" {
  skip_tls_verify = "true"
}
