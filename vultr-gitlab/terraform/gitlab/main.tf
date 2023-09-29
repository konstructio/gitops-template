terraform {
  backend "s3" {
    endpoint = "<KUBEFIRST_STATE_STORE_BUCKET_HOSTNAME>"
bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key      = "terraform/gitlab/terraform.tfstate"

    // Don't change this.
    // https://www.vultr.com/docs/how-to-store-terraform-state-in-vultr-object-storage/
    region = "us-east-1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
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
