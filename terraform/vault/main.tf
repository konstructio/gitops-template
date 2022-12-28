terraform {
  backend "s3" {
    bucket  = "<TF_STATE_BUCKET>"
    key     = "terraform/vault/tfstate.tf"
    region  = "<AWS_DEFAULT_REGION>"
    encrypt = true
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.39.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "3.20.0"
    }
  }
}
